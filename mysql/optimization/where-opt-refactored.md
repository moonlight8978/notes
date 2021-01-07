---
source code: /tree/mysql/optimization/query-1
---

# MySQL Optimization

Có 2 hướng tối ưu chính:

### 1. Tối ưu tầng DB

##### Cấu trúc DB:

- Đọc nhiều => ít table, nhiều column
- Ghi nhiều => nhiều table, ít column

##### Index đã ổn chưa?

##### Engine cho table

- MyISAM: Table-locking, phù hợp với table đọc nhiều, ghi ít
- InnoDB: Row-locking, đáp ứng được việc ghi nhiều.

##### Caching

### 2. Tối ưu phần cứng

##### Disk seek:

- Thời gian HDD quay khi tìm dữ liệu, SDD không cần quay để tìm dữ liệu.

- Phân tán dữ liệu để tìm trên nhiều ổ đĩa cùng lúc.

##### Disk R/W:

- Khi tìm được dữ liệu thì sẽ cần đọc dữ liệu vào RAM.

- Phân tán để đọc/ghi nhiều trên nhiều ổ đĩa cùng lúc.

##### CPU cycle

- Khi đã load được vào RAM rồi, thì sẽ tới CPU xử lý những dữ liệu đó.

##### Memory bandwidth:

- Khi CPU cần nhiều dữ liệu, nhưng cache lại không đủ, sẽ cần đến memory bandwith.

# Tối ưu tầng DB - Tối ưu SELECT

## 1. WHERE clause optimization

##### Ngoài SELECT thì còn áp dụng được cho cả UPDATE, DELETE, v.v.

##### MySQL sẽ tự động tối ưu những trường hợp sau:

- Loại bỏ những dấu ngoặc thừa

  ```sql
  ((a AND b) AND c OR (((a AND b) AND (c AND d))))
  => (a AND b AND c) OR (a AND b AND c AND d)
  ```

- Thay thế biến bởi hằng số

  ```sql
  (a<b AND b=c) AND a=5
  => b>5 AND b=c AND a=5
  ```

- Loại bỏ những điều kiện hằng

  ```sql
  (b>=5 AND b=5) OR (b=6 AND 5=5) OR (b=7 AND 5=6)
  => b=5 OR b=6
  ```

- Biểu thức hằng (constant expression) sẽ chỉ được tính toán 1 lần duy nhất.

  ```sql
  SELECT *
  FROM t
  WHERE id = POW(1,2);

  SELECT *
  FROM t
  WHERE id = FLOOR(1 + RAND() * 49);
  ```

- `HAVING` sẽ được gộp với `WHERE` khi không sử dụng `GROUP BY` hay những function như `COUNT()`, `MIN()`, `MAX()`, ...

- Đối với **MyISAM** hay **MEMORY** table, kết quả của `COUNT(*)` (không có điều kiện `WHERE` sẽ được lấy trực tiếp từ **information_schema**.

=> Ta có thể ngừng việc tối ưu lại, và viết những câu lệnh SQL dễ hiểu, dễ bảo trì.

## 2. Range optimization

- `range` là một **access method**
- `range` sử dụng index để lấy ra những subset của kết quả cuối cùng.
- `range` support cả single-part lẫn multiple-part index.

#### Những trường hợp sau, MySQL sẽ coi như là `range condition`:

- Mệnh đề `WHERE` đối với những trường được đánh index (sử dụng BTree hoặc Hash), mà sử dụng những toán tử sau: `=`, `<=>`, `IN()`, `IS NULL`, hay `IS NOT NULL`

  Đối với, BTree, ngoài những phép toán trên, còn support thêm `>`, `<`, `<=`, `>=`, `BETWEEN`, `!=`, hay `<>` với **constant value**, hoặc `LIKE` cũng là range condition. Chú ý khi sử dụng `LIKE`, vế phải phải là 1 string hằng, và không bắt đầu bởi wildcard như `%` hay `_`.

  ```sql
  SELECT *
  FROM t1
  WHERE key_col LIKE 'ab%';
  ```

- Kết hợp nhiều range condition sử dụng `AND` hoặc `OR`, ta vẫn thu được range condition.

#### Constant value

##### Là giá trị được tính toán trước thời điểm runtime, khi runtime, giá trị của nó sẽ không thay đổi

- Hằng số truyền thẳng vào tham số của câu truy vấn
- Một cột của `const` hay `system` table
  - `const` table là bảng chỉ có tối đa 1 row (hay 0 hoặc 1 row).
  - `const` table có thể là kết quả của 1 câu truy vấn chứa mệnh đề `WHERE` đối với 1 field unique, not null, có dạng `column = constant`. Truy vấn này luôn trả về 1 kết quả duy nhất.
  - table có 1 row thì gọi là `system` table

#### BTree, Hash index

##### BTree:

- Self-balancing tree, cấu trúc dạng cây, có thể tự cân bằng nhằm giữ chiều cao của cây thấp nhất có thể.
- Tránh nhầm với Binary Tree (cây nhị phân)

- Thời gian tìm kiếm O(logn)

- Phù hợp với đa dạng các phép toán: `=`, `<=>`, `IN()`, `IS NULL`, `IS NOT NULL`, `>`, `<`, `<=`, `>=`, `BETWEEN`, `!=`, `<>`, hay thậm chí cả `LIKE`

![](https://camo.githubusercontent.com/cb15fccfa6fafa1cea762a58c1dd51ad8f32fe2c/68747470733a2f2f63646e2d696d616765732d312e6d656469756d2e636f6d2f6d61782f313630302f312a70453453457a374370727a4664375a77772d617866512e6a706567)

##### Hash:

- Bảng băm, là cấu trúc dữ liệu lưu theo key-value

- Tìm kiếm theo key rất nhanh - O(1)

- Phù hợp với những phép toán: `=`, `<=>`, `IN()`, `IS NULL`, hay `IS NOT NULL`.

![](https://camo.githubusercontent.com/b1df2be12b1c8779b7cf941d88d1cc8e2178753f/68747470733a2f2f696d616765732e7669626c6f2e617369612f30356236313638372d386230342d346536352d613834642d3361353363343035386437642e6a7067)

### 2.1. Single-part index

##### Single-part index là những index được đánh riêng lẻ cho 1 field.

```sql
CREATE INDEX index_name ON t1 (key_col);
```

Khi thực hiện truy vấn với những index loại này, với mỗi possible key (có thể sử dụng `EXPLAIN` để check), MySQL sẽ tiến hành extract range condition. Những điều kiện không thể cấu thành range condition sẽ bị loại bỏ, những điều kiện có thể bị overlap sẽ được gộp với nhau.

Sau khi extract, MySQL sẽ áp dụng những điều kiện đó để tận dụng được tối đa index của table, sau đó kết hợp thêm với những điều kiện còn lại để lọc tiếp.

MySQL chỉ bỏ qua index, nếu như nó tin rằng việc duyệt full table tối ưu hơn, hoặc dùng `FORCE INDEX`.

VD:

```sql
SELECT *
FROM t1
WHERE (
	(key1 < 'abc' AND (key1 LIKE 'abcde%' OR key1 LIKE '%b'))
	OR (key1 < 'bar' AND nonkey = 4)
	OR (key1 < 'uux' AND key1 > 'z')
);

=> (key1 < 'abc' AND (key1 LIKE 'abcde%' OR TRUE)) OR
(key1 < 'bar' AND TRUE) OR
(key1 < 'uux' AND key1 > 'z')

=> (key1 < 'abc' AND TRUE) OR (key1 < 'bar' AND TRUE) OR (FALSE)

=> key1 < 'abc' OR key1 < 'bar'

=> key1 < 'bar'
```

### 2.2. Multiple-part index

##### Multiple-Part Index là những index được đánh cho nhiều trường cùng lúc

```sql
CREATE INDEX index_name ON t1 (key_part1, key_part2)
```

Range condition sẽ sử dụng **key tuple intervals** để tìm kiếm. Key tuple intervals được định nghĩa bởi những key tuples, có thứ tự.

**Tuple** là 1 cặp giá trị. VD: (1, 2, 3), (1, 'a', 3), ...

Lấy ví dụ về 1 multiple-part index `key1(key_part1, key_part2, key_part3)`, và những tuples ứng với key tuple (key_part1, key_part2, key_part3) sau:

```txt
key_part1  key_part2  key_part3
  NULL       1          'abc'
  NULL       1          'xyz'
  NULL       2          'foo'
   1         1          'abc'
   1         1          'xyz'
   1         2          'abc'
   2         1          'aaa'
```

`key_part1 = 1` define interval sau:

```txt
(1,-inf,-inf) <= (key_part1,key_part2,key_part3) < (1,+inf,+inf)
```

Interval trên sẽ được sử dụng bởi `range` access method.

Bên cạnh đó, `key_part3 = 'abc'` không tạo ra interval nào (giá trị liền mạch nhau), vì thế sẽ không thể sử dụng bởi `range`

Chú ý khi sử dụng:

- Với Hash index, nếu index có `N` part, thì condition của ta phải có format sau

  ```sql
      key_part1 cmp const1
  AND key_part2 cmp const2
  AND ...
  AND key_partN cmp constN;
  ```

  `cmp` là một trong những toán tử `=`, `<=>`, hoặc `IS NULL`

- Với BTree index, 1 interval có thể sử dụng cho những điều kiện kết hợp bởi `AND`, trong đó mỗi điều kiện so sánh 1 key part với 1 hằng số, sử dụng `=`, `<=>`, `IS NULL`, `>`, `<`, `>=`, `<=`, `!=`, `<>`.

  Optimizer trong khi tính toán interval, sẽ sử dụng thêm key part nếu toán tử là `=`, `<=>` hay `IS NULL`. Còn nếu là `>`, `<`, `>=`, `<=`, `!=`, `<>`, `BETWEEN` hay `LIKE` thì sẽ không lấy thêm key part nữa.

  VD1:

  ```sql
  key_part1 = 'foo' AND key_part2 >= 10 AND key_part3 > 10
  ```

  sẽ sử dụng interval:

  ```sql
  ('foo',10,-inf) < (key_part1,key_part2,key_part3) < ('foo',+inf,+inf)
  ```

  VD2:

  ```sql
  (key_part1 = 1 AND key_part2 < 2) OR (key_part1 > 5)
  ```

  sẽ sử dụng 2 interval:

  ```sql
  (1,-inf) < (key_part1,key_part2) < (1,2)
  (5,-inf) < (key_part1,key_part2)
  ```

  Trong ví dụ này, interval thứ nhất sử dụng 1 key part ở vế trái, vế phải sử dụng 2 key part.

  Interval thứ 2 chỉ sử dụng 1 key part.

  Giá trị `key_len` khi thực hiện `EXPLAIN` sẽ trả về độ dài tối đa của key prefix được sử dụng.

### Index Dive

Index dive được thực hiện trong khi optimizing để tính toán estimate (số row thỏa mãn 1 condition), để quyết định xem có nên dùng index hay không. Có thể skip bằng cách dùng `FORCE INDEX`

Nếu điều kiện phức tạp thì index dive sẽ mất nhiều thời gian.

Ngoài index dive, MySQL cũng có thể sử dụng index statistics để estimate, tuy nhiên độ chính xác thấp hơn, có thể dùng `ANALYZE TABLE` để update lại index statistics, tăng cường độ chính xác.

Index dive bị skip trong trường hợp thỏa mãn tất cả điều kiện sau (chỉ áp dụng cho single table query):

- `FORCE INDEX`
- Nonunique index, và không phải `FULLTEXT` index.
- Không có subquery
- Không có `DISTINCT`, `GROUP BY`, hoặc `ORDER BY`.

##### Equality Range Optimization of Many-Valued Comparisons

```sql
col_name IN(val1, ..., valN)
col_name = val1 OR ... OR col_name = valN
```

Những biểu thức như trên, với `col_name` được đánh index, và so sánh với nhiều giá trị, được gọi là range comparisions (mỗi range là 1 giá trị). Optimizer sẽ estimate cost của mỗi range như sau:

- Nếu index là unique, cost = 1
- Nếu không unique, sẽ cần sử dụng index dive hoặc index statistics để estimate.

Ứng với mỗi range là 2 lần dive (1 cho điểm bắt đầu, 1 cho điểm kết thúc) của range (interval).
