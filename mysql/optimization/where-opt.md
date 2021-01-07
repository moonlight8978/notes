Thuật ngữ

- **constant expression**: biểu thức hằng, là biểu thức có thể tính toán được giá trị trong khi compile, giá trị của nó không thay đổi tại runtime.

- **BTree**: Self-balancing tree, cấu trúc dạng cây, có thể tự cân bằng nhằm giữ chiều cao của cây thấp nhất có thể

  ![](https://cdn-images-1.medium.com/max/1600/1*pE4SEz7CprzFd7Zww-axfQ.jpeg)

- **HASH**: Bảng băm, là cấu trúc dữ liệu lưu theo key-value

  ![](https://images.viblo.asia/05b61687-8b04-4e65-a84d-3a53c4058d7d.jpg)

## Tối ưu SELECT

#### WHERE optimization

Đôi lúc ta sẽ bị cám dỗ bởi việc viết lại những câu lệnh SQL để tăng hiệu năng, tuy nhiên lại hy sinh đi tính dễ đọc của câu lệnh.

Tuy nhiên nhiều khi MySQL sẽ tự động tối ưu hóa nó, nên ta có thể ngừng việc tối ưu lại, và viết những câu lệnh SQL dễ hiểu hơn.

MySQL sẽ tự động tối ưu những trường hợp sau:

- Loại bỏ những dấu ngoặc thừa

```sql
((a AND b) AND c OR (((a AND b) AND (c AND d))))
-> (a AND b AND c) OR (a AND b AND c AND d)
```

- Sắp xếp lại những hằng số

```sql
(a<b AND b=c) AND a=5
```

MySQL sẽ sử dụng giá trị `5` thay cho biến `a`

```sql
b>5 AND b=c AND a=5
```

- Loại bỏ những điều kiện hằng

```sql
(b>=5 AND b=5) OR (b=6 AND 5=5) OR (b=7 AND 5=6)
```

Dễ thấy rằng `b>=5 AND b=5` nếu áp dụng cách tối ưu thứ (2), sẽ trở thành `5>=5 AND b=5`, tương đương `b=5` do `5>=5` luôn đúng

`b=6 AND 5=5` có thể viết gọn thành `b=6`

`b=7 AND 5=6` thì luôn trả về `false` nên có thể loại bỏ đi

Từ đó ta có thể thay thế điều kiện hại não trên bởi

```sql
b=5 OR b=6
```

- Khi query sử dụng index với 1 biểu thức hằng, biểu thức đó sẽ chỉ được tính toán 1 lần duy nhất.

  MySQL sẽ tính toán giá trị của biểu thức hằng trước khi thực thi câu lệnh, giá trị đó sẽ được tái sử dụng, MySQL không mất công tính toán lại biểu thức cho mỗi row khi tìm kiếm.

Xét 2 query sau:

```sql
SELECT *
FROM t
WHERE id = POW(1,2);

SELECT *
FROM t
WHERE id = FLOOR(1 + RAND() * 49);
```

`POW(1,2)` luôn trả về giá trị `2`. Những hàm như vậy hay còn được gọi là **deterministic function**

Còn với query thứ 2, do sự xuất hiện của hàm `RAND()`, nếu nghĩ rằng hàm trên tìm kiếm row có id bất kì thì bạn đã nhầm to. Vì `RAND()` có giá trị khác nhau ngay cả trong khi MySQL tìm kiếm mỗi row của bảng t. Vì vậy nếu có n row thì hàm này sẽ chạy n lần chỉ trong 1 query. Những hàm kiểu này còn được gọi là **nondeterministic function**

- `HAVING` sẽ được gộp với `WHERE` khi không sử dụng `GROUP BY` hay những function như `COUNT()`, `MIN()`, `MAX()`, ...

- Một số trường hợp trường được đánh index có kiểu dữ liệu số (numeric), MySQL thậm chí không cần đọc dữ liệu của trường đó trong file vật lý, chỉ duyệt index tree cũng có thể lấy được dữ liệu của trường đó.

VD: Giả sử DB ta có đánh index cho `(key_part1, key_part2)`, cả 2 trường đều có kiểu dữ liệu số. Câu query sau sẽ chỉ dùng tới index tree.

```sql
SELECT key_part1, key_part2
FROM tbl_name
WHERE key_part1=val;
```

- Đối với **MyISAM** hay **MEMORY** table, khi thực hiện truy vấn `COUNT(*)` trên 1 bảng mà không sử dụng `WHERE`, kết quả sẽ được lấy trực tiếp từ **information_schema** thay vì tìm kiếm trong DB, vì vậy sẽ rất nhanh.

#### Range optimization

`range` sử dụng index single index để lấy ra 1 subset các row nằm trong 1 hoặc nhiều **interval** (sẽ giải thích ở dưới). Index có thể là single-part index hoặc multiple-part index

###### Range optimization for Single-part index

Single-part index là những index được đánh riêng lẻ cho 1 field.

```sql
CREATE INDEX index_name ON t1 (key_col);
```

Những trường hợp sau là **range condition**

- Đối với index sử dụng **BTREE** hay **HASH**, những biểu thức so sánh với **constant value** sử dụng `=`, `<=>`, `IN()`, `IS NULL`, hay `IS NOT NULL` là range condition.

```sql
SELECT *
FROM t1
WHERE key_col IN (15, 18, 20);
```

- Với **BTREE**, ngoài những biểu thức trên, những phép so sánh `>`, `<`, `<=`, `>=`, `BETWEEN`, `!=`, hay `<>` với **constant value**, hoặc `LIKE` cũng là range condition.

  `LIKE` là range condition khi mà vế phải là một constant string, và không bắt đầu bởi kí tự wildcard (như `%`, và `_`)

```sql
SELECT *
FROM t1
WHERE key_col LIKE 'ab%';
```

- Kết hợp nhiều range condition sử dụng `AND` hoặc `OR`, kết quả vẫn là range condition

```sql
SELECT *
FROM t1
WHERE key_col > 1 AND key_col < 10;
```

**NOTE:** constant value được đề cập ở trên được định nghĩa như sau:

- Hằng số truyền thẳng vào tham số của câu truy vấn

- Một cột của `const` hay `system` table

  - `const` table là bảng chỉ có tối đa 1 kết quả sau khi query.

    VD:

    ```sql
    SELECT * FROM tbl_name WHERE primary_key=1;

    SELECT *
    FROM tbl_name
    WHERE primary_key_part1=1 AND primary_key_part2=2;
    ```

    Cả 2 trường hợp trên, kết quả sau khi truy vấn đều chỉ có 1 row. Optimizer của MySQL sẽ thực hiện tối ưu khi ta sử dụng bảng này trong quá trình truy vấn, những giá trị của bảng này sẽ được coi như hằng số.

  - `system` table là một trường hợp đặc biệt hơn, nó là 1 bảng chỉ có 1 row.

MySQL sẽ tiến hành extract **range condition** từ mệnh đề **WHERE** với mỗi **possible index** (những index có khả năng sử dụng khi thực hiện query hiện tại). Khi tiến hành extract, những điều kiện không thể cấu thành range condition sẽ bị loại bỏ, những điều kiện có thể bị overlap sẽ được gộp với nhau.

Sau khi extract, MySQL sẽ áp dụng những điều kiện đó để tận dụng được tối đa index của table, sau đó kết hợp thêm với những điều kiện còn lại để lọc tiếp.

Lấy ví dụ bảng `t1` với `key1` được đánh index, và `nonkey` không được đánh index. Ta xét câu truy vấn dưới đây:

```sql
SELECT *
FROM t1
WHERE (
	(key1 < 'abc' AND (key1 LIKE 'abcde%' OR key1 LIKE '%b'))
	OR (key1 < 'bar' AND nonkey = 4)
	OR (key1 < 'uux' AND key1 > 'z')
);
```

MySQL sẽ tiến hành extract cho index `key1` như sau:

- `nonkey` không được đánh index => bỏ điều kiện `nonkey = 4`
- `'%b'` bắt đầu bằng wildcard `%` => bỏ điều kiện `key1 LIKE '%b'`

Những điều kiện trên sẽ được thay thế bằng `TRUE`, ta thu được:

```sql
(key1 < 'abc' AND (key1 LIKE 'abcde%' OR TRUE)) OR
(key1 < 'bar' AND TRUE) OR
(key1 < 'uux' AND key1 > 'z')
```

Loại bỏ những điều kiện luôn đúng hoặc luôn sai:

- `key1 LIKE 'abcde%' OR TRUE` luôn đúng

- `(key1 < 'uux' AND key1 > 'z')` luôn sai (do `z` đứng sau `u` trong bảng chữ cái)

```sql
(key1 < 'abc' AND TRUE) OR (key1 < 'bar' AND TRUE) OR (FALSE)
=> key1 < 'abc' OR key1 < 'bar'
```

Kết hợp 2 điều kiện, chỉ còn

```sql
key1 < 'bar'
```

Sau khi dùng điều kiện này để thực hiện range search, MySQL sẽ kết hợp với những điều kiện còn lại để query tiếp.

###### Multiple-Part Indexes

Multiple-Part Index là những index được đánh cho nhiều trường cùng lúc

```sql
CREATE INDEX index_name ON t1 (key_part1, key_part2);
```

Khi tạo 1 multiple-part index, MySQL sẽ tạo ra **interval** (sẽ giải thích ở dưới), gồm nhiều `set of key tuples`, được sắp xếp có trật tự.

Lấy ví dụ với index `key1(key_part1, key_part2, key_part3)`

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

Interval ứng với `key_part1 = 1` sẽ là:

```txt
(1,-inf,-inf) <= (key_part1,key_part2,key_part3) < (1,+inf,+inf)
```

Tương đương với cặp thứ 4, 5, và 6 trong bảng trên, và những cặp đó sẽ được sử dụng trong range search.

- Với **HASH** index, khi query, ta phải sử dụng tất cả key part của index để truy vấn, mệnh đề `WHERE` của ta sẽ có dạng như sau:

```sql
 	key_part1 cmp const1
AND key_part2 cmp const2
AND ...
AND key_partN cmp constN;
```

`cmp` có thể là `=`, `<=>`, hoặc `IS NULL`

- Với **BTREE** index, interval có thể được sử dụng trong range search khi sử dụng `AND`, mỗi điều kiện đều so sánh với hằng số, và sử dụng các toán tử `=`, `<=>`, `IS NULL`, `>`, `<`, ... (giống phần định nghĩa range condition ở đầu)

  Khi `WHERE` có nhiều điều kiện, optimizer sẽ xét thêm key_part tiếp theo, lắp vào interval bên dưới để quyết định xem interval nào sẽ được sử dụng để thực hiện range search khi toán tử là `=`, `<=>`, hay `IS NULL`.

  ```txt
  (-inf,-inf,-inf,...) <= (key_part1,key_part2,key_part3,...) < (+inf,+inf,+inf,...)
  ```

  Nếu là những toán tử khác, optimizer sẽ dừng lại.

  **BTREE** chỉ có thể sử dụng index, nếu chúng là _leftmost prefix_

  VD:

  ```sql
  key_part1 = 'foo' AND key_part2 >= 10 AND key_part3 > 10
  ```

  Điều kiện thứ nhất sử dụng `=`, optimizer sẽ lấy thêm `key_part2` cho vào interval, do điều kiện thứ 2 là `>=`, optimizer sẽ dừng lại, không sử dụng `key_part3` nữa.

  Interval được sử dụng cho range search sẽ là

  ```txt
  ('foo',10,-inf) < (key_part1,key_part2,key_part3) < ('foo',+inf,+inf)
  ```

- Khi query sử dụng `OR` => union của interval

  Khi sử dụng `AND` => lấy phần chung của interval

  VD:

  ```sql
  (key_part1 = 1 AND key_part2 < 2) OR (key_part1 > 5)
  ```

  Sẽ tạo ra những interval:

  ```txt
  (1,-inf) < (key_part1,key_part2) < (1,2)
  (5,-inf) < (key_part1,key_part2)
  ```

###### Equality Range Optimization of Many-Valued Comparisons

Giả sử `col_name` là một cột được đánh index.

```sql
col_name IN(val1, ..., valN)
col_name = val1 OR ... OR col_name = valN
```

Ở những biểu thức trên, `col_name` có thể nhận nhiều giá trị. Những điều kiện như vậy, gọi là **equality range comparison**

Nếu `col_name` có unique index, optimizer sẽ estimate việc đọc dữ liệu ở từng range là 1, vì đã unique thì chỉ có 1 giá trị thỏa mãn.

Khi không unique, optimizer sẽ đi sâu vào (dive into) index (index dive) hoặc sử dụng index statistics để estimate. Việc estimate này dùng để xác định xem có cần dùng index để query hay không. Thông thường index sẽ được sử dụng, trừ khi optimizer thấy fullscan tốt hơn.

Index dive dùng để xác định số row trong 1 range, thường sẽ thực hiện 2 lần: 1 để tìm start row (min value), 2 là end row (max value).

Khi dive, nếu điều kiện phức tạp thì sẽ mất nhiều thời gian hơn.

Index dive có độ chính xác tốt hơn index statistics.

Có thể dùng `ANALYZE TABLE` để update lại index statistics, cải thiện độ chính xác.

Những trường hợp sau sẽ skip index dive:

- `FORCE INDEX`. Vì index đã được force apply rồi nên index dive không còn ý nghĩa gì nữa.
- Nonunique index và không phải `FULLTEXT` index.
- Không có subquery
- Không có `DISTINCT`, `GROUP BY`, hay `ORDER BY`

Những trường hợp trên chỉ áp dụng với single-table query, không áp dụng cho multiple-table query (joins bảng).

#### Index Merging

- Index Merge được sử dụng để merge kết quả từ nhiều range scan.

- Chỉ hoạt động với single table, toạc khi join nhiều bảng

- Một số trường hợp có điều kiện AND/OR phức tạp, MySQL sẽ không thể chọn được phương án tối ưu, nếu có thể, ta nên sửa điều kiện truy vấn:

  ```sql
  (x AND y) OR z => (x OR z) AND (y OR z)
  (x OR y) AND z => (x AND z) OR (y AND z)
  ```

- Kết quả của index merging sẽ được hiển thị ở cột Extra khi sử dụng `EXPLAIN`, index merging có những thuật toán sau:

  - Using intersect(...)
  - Using union(...)
  - Using sort_union(...)

###### Intersect

- Thuật toán được áp dụng khi mệnh đề `WHERE` sử dụng 1 số range condition trên những key khác nhau được kết hợp bởi `AND`, mỗi condition thỏa mãn 1 trong số điều kiện sau:

  - biểu thức n-part, index sử dụng cũng có đúng n part (tất cả index part đều được cover)

    ```sql
    key_part1 = const1 AND key_part2 = const2 ... AND key_partN = constN
    ```

  - range condition trên primary key của InnoDB table

- MySQL sẽ thực hiện scan đối với tất cả index được sử dụng 1 cách đồng thời, sau đó lấy giao của những kết quả với nhau.

- > If the used indexes do not cover all columns used in the query, full rows are retrieved only when the range conditions for all used keys are satisfied.

  Nếu index được sử dụng không cover được hết điều kiện trong query, full row sẽ chỉ được lấy khi mà tất cả range condition cho những key đã sử dụng đều thỏa mãn. Còn không thì sẽ chỉ lấy ra những trường cần thiết để check điều kiện

- Đối với InnoDB table, khi sử dụng primary trong range condition, MySQL sẽ không dùng nó để scan mà sẽ dùng để filter kết quả sau khi scan bằng những index khác.

  ```sql
  EXPLAIN SELECT * FROM users WHERE username LIKE 'ch' AND email LIKE 'ch' AND gender = 'male' AND name LIKE 'T';
  ```

###### Merge Union

- Điều kiện giống với Intersect nhưng dùng `OR` thay vì `AND`:

  - điều kiện mà có thể áp dụng thuật toán intersection.

  ```sql
  EXPLAIN SELECT * FROM users WHERE username LIKE 'ch' AND email LIKE 'ch' AND gender = 'male' OR name LIKE 'T';
  ```

###### Merge Sort-Union

- Thuật toán sort-union được áp dụng khi những range condition được kết hợp bởi `OR`, nhưng không thể áp dụng union.

- Điểm khác so với thuật toán union là sort-union phải fetch ID, sort, sau đó mới return lại value.

  ```sql
  EXPLAIN SELECT * FROM users WHERE username LIKE 'ch' AND email LIKE 'ch' OR name LIKE 'T';
  ```

  Câu truy vấn trên không áp dụng được union vì:

  - `username LIKE 'ch' AND email LIKE 'ch'` chỉ có 2 điều kiện, trong khi index của ta có 3 part.
