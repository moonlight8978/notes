---
title: MySQL Subquery optimization
code: /tree/mysql/optimization/subquery
---

# Optimize Subquery với Semijoin transformation

**Hoàng thùy link:** https://dev.mysql.com/doc/refman/5.7/en/semijoins.html

#### Semijoin là gì

**Semijoin** là quá trình chuẩn bị trước khi query, optimizer của MySQL có thể sử dụng nhiều strategy như table pullout, duplicate weedout, first match, loose scan, hay materizalization để tối ưu câu lệnh subquery.

#### Ví dụ về semijoin

Giả sử ta có db về quản lý lớp học, `subject` là danh sách tất cả các môn học, `roster` là bảng join của `student` với `subject` nhằm thể hiển học sinh đã đăng kí học môn nào. Quan hệ giữa `subject` và `student` là many to many.

Query sau đây sẽ lấy ra được những `subject` có học sinh đăng kí.

```SQL
SELECT subject.id, subject.name
FROM subject INNER JOIN roster
WHERE subject.id = roster.subject_id;
```

Tuy nhiên do là quan hệ many to many, nên trong bảng `roster` có thể có nhiều `subject_id` bị trùng lặp. Nên kết quả của query trên có thể sẽ bị duplicate.

Ta có thể sử dụng `SELECT DISTINCT` để giải quyết vấn đề này. Tuy nhiên việc query tất, rồi khử đi những giá trị trùng lặp như vậy là không tối ưu.

Ta có thể giải quyết vấn đề trên bằng việc dùng subquery.

```sql
SELECT subject.id, subject.name
FROM subject INNER JOIN roster
WHERE subject.id IN (SELECT subject_id FROM roster);
```

Câu truy vấn vừa rồi chúng ta sử dụng sẽ sử dụng semijoin.

Câu truy vấn chính (outer query) có thể sử dụng outer join hoặc inner join. Và reference table có thể là base table, derived table hoặc view.

#### Điều kiện để subquery là một semiquery

Subquery phải thỏa mãn những điều kiện sau:

- Phải là `IN` (hoặc `=ANY`) subquery, đặt trong mệnh đề `WHERE` hoặc `ON` ở top-level.
- Không dùng `UNION`.
- Không có mệnh đề `GROUP BY` hoặc `HAVING`, các aggregate functions.
- Không có `ORDER BY` đi kèm với `LIMIT`, chỉ có `ORDER_BY` thôi thì okay.
- Outer query không dùng `STRAIGHT_JOIN`
- Không có `STRAIGHT_JOIN` trong subquery.
- Tổng số table cả trong inner query lẫn outer query bé hơn 61 (maximum number of tables permitted in a join)

#### Strategy

Nếu thỏa mãn những điều kiện trên, MySQL sẽ convert subquery thành semijoin và thực hiện tính toán cost, rồi chọn một trong những strategy sau:

- Table pullout: Convert subquery thành join. Hoặc sẽ lấy table trong inner query ra, truy vấn, sau đó inner join với outer table.

- [Duplicate Weedout](https://mariadb.com/kb/en/library/duplicateweedout-strategy/): Join table, lấy ra toàn bộ kết quả trước, sau đó sử dụng bảng tạm để remove đi những giá trị duplicate

  ```sql
  select * from Country
  where
     Country.code IN (select City.Country
                      from City
                      where
                        City.Population > 0.33 * Country.Population and
                        City.Population > 1*1000*1000);
  ```

  ![duplicate-weedout-diagram](https://mariadb.com/kb/en/duplicateweedout-strategy/+image/duplicate-weedout-diagram)

- [First Match](https://mariadb.com/kb/en/library/firstmatch-strategy/): inner join table, khi tìm được một kết quả thỏa mãn, nó sẽ return luôn, không tìm giá trị tiếp theo nữa để tránh duplicate

  ```sql
  select * from Country
  where Country.code IN (select City.Country
                         from City
                         where City.Population > 1*1000*1000)
        and Country.continent='Europe'
  ```

  ![firstmatch-firstmatch](https://mariadb.com/kb/en/firstmatch-strategy/+image/firstmatch-firstmatch)

- [Loose Scan](https://mariadb.com/kb/en/library/loosescan-strategy/): Scan subquery table bằng index, group những giá trị giống nhau lại thành từng group, rồi lấy một giá trị từ mỗi group.

  ```sql
  select * from Country
  where
    Country.code in (select country_code from Satellite)
  ```

  ![loosescan-diagram-no-where](https://mariadb.com/kb/en/loosescan-strategy/+image/loosescan-diagram-no-where)

- Materialization: Đề cập riêng ở dưới

#### Một vài lưu ý:

- Có thể enable/disable semijoin, strategy bằng biến `optimizer_switch`

- Khi disable `duplicateweedout`, strategy này sẽ không được sử dụng trừ khi tất cả những strategy khác đều không áp dụng được để tối ưu.

#### EXPLAIN query

- Semijoin table sẽ được hiển thị ở outer select
- Temporary table được sử dụng sẽ được chỉ ra bằng **Start temporary** và **End temporary** trong cột `extra`

- **FirstMatch(table_name)** trong cột `extra` cho ta biết shortcut đã được dùng trong strategy First Match.
- **LooseScan(m..n)** trong cột `extra` chỉ ra rằng Loose Scan đã được áp dụng, m, n là key part number.

- Temporary table dùng cho materialization được chỉ ra bằng những row có **select_type** của **MATERIALIZED** và những row có **table** của **subqueryN**

# Materialization

#### Materialization là gì

Khi thấy subquery và outer query là cùng bố khác ông nội (chả liên quan gì tới nhau), thì subquery hoàn toàn có thể tách riêng ra, thực thi 2 query độc lập, cuối cùng join 2 table đó với nhau. Ý tưởng của strategy này là như vậy.

Khi sử dụng strategy này, trước hết MySQL sẽ query subquery, sau đó lấy kết quả để tạo 1 bảng tạm (materialize), đánh index để remove duplicate, cuối cùng join với outer table.

```sql
select * from Country
where Country.code IN (select City.Country
                       from City
                       where City.Population > 7*1000*1000)
      and Country.continent='Europe'
```

![sj-materialization1](https://mariadb.com/kb/en/semi-join-materialization-strategy/+image/sj-materialization1)

Khi thực hiện phép join với outer table, có 2 hướng:

- Join từ bảng tạm vào outer table

  Nếu làm vậy, ta sẽ phải thực hiện fullscan bảng tạm, sau đó lookup những giá trị đó trong outer table

  => gọi là Materialization-scan

- Join từ outer table vào bảng tạm

  Khi đó ta sẽ dùng giá trị ở outer table để lookup trong bảng tạm

  => gọi là Materialization-lookup

#### Điều kiện

- ```sql
  (oe_1, oe_2, ..., oe_N) [NOT] IN (SELECT ie_1, i_2, ..., ie_N ...)
  ```

Nếu predicate có form như trên, `oe_1` và `ie_1` không được null.

- ```sql
  oe [NOT] IN (SELECT ie ...)
  ```

Predicate form này chấp nhận giá trị null.

- Outer expression và inner expression phải có cùng kiểu dữ liệu
- Inner expression không được là kiểu `BLOB`

#### Rewrite SQL

Khi disable materialization semijoin đi, MySQL có thể sẽ convert câu lệnh subquery của ta.

VD:

```sql
SELECT * FROM t1
WHERE t1.a IN (SELECT t2.b FROM t2 WHERE where_condition);
```

Ở ví dụ trên, subquery hoàn toàn không liên quan gì tới outer query, nếu bình thường là có thể dùng materialization rồi, nhưng nếu ta disable đi, MySQL sẽ convert lại thành như sau:

```sql
SELECT * FROM t1
WHERE EXISTS (SELECT t2.b FROM t2 WHERE where_condition AND t1.a=t2.b);
```

Inner query và outer query đã trở thành láng giềng với nhau.

Và cứ mỗi row của `t1`, sẽ phải lookup 1 lần trong subquery table, khá thốn.

#### Example

Database structure: [link](https://github.com/moonlight8978/rsch-glr/blob/mysql/subquery/mysql-optimization/subquery/db/schema.rb)

###### First Match

```sql
explain select cities.name from cities where id IN (select city_id from populations where number > 5000000)\G
```

```txt
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: cities
   partitions: NULL
         type: ALL
possible_keys: PRIMARY
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 7
     filtered: 100.00
        Extra: NULL
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: populations
   partitions: NULL
         type: ALL
possible_keys: index_populations_on_city_id
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 7
     filtered: 33.33
        Extra: Using where; FirstMatch(cities); Using join buffer (Block Nested Loop)
2 rows in set, 1 warning (0.00 sec)
```

###### Loose Scan

```sql
explain select cities.name from cities where id IN (select city_id from satellites)\G
```

```txt
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: satellites
   partitions: NULL
         type: index
possible_keys: index_satellites_on_city_id
          key: index_satellites_on_city_id
      key_len: 9
          ref: NULL
         rows: 4
     filtered: 50.00
        Extra: Using where; Using index; LooseScan
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: cities
   partitions: NULL
         type: eq_ref
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 8
          ref: app_development.satellites.city_id
         rows: 1
     filtered: 100.00
        Extra: NULL
2 rows in set, 1 warning (0.00 sec)
```

Đoạn explain trên chỉ ra rằng, bảng `satellites` đã được áp dụng strategy LooseScan, nó sẽ group những giá trị giống nhau lại, và lấy ra 1 giá trị trong mỗi group.

Cuối cùng join với bảng `cities` với access_method `eq_ref`.

###### Materialization

```sql
set session optimizer_switch='duplicateweedout=off,firstmatch=off,loosescan=off';
explain select cities.name from cities where id IN (select city_id from populations where number > 5000000)\G
```

```txt
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: cities
   partitions: NULL
         type: ALL
possible_keys: PRIMARY
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 7
     filtered: 100.00
        Extra: Using where
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: <subquery2>
   partitions: NULL
         type: eq_ref
possible_keys: <auto_key>
          key: <auto_key>
      key_len: 9
          ref: app_development.cities.id
         rows: 1
     filtered: 100.00
        Extra: NULL
*************************** 3. row ***************************
           id: 2
  select_type: MATERIALIZED
        table: populations
   partitions: NULL
         type: ALL
possible_keys: index_populations_on_city_id,index_populations_on_number
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 7
     filtered: 57.14
        Extra: Using where
3 rows in set, 1 warning (0.00 sec)
```

- Row 3 cho thấy bảng populations đã được query, nhưng với điều kiện `population > 5000000` thì không có index nào được dùng, và nó thực hiện fullscan. MySQL dùng kết quả đó để tạo nên materialized table, chính là bảng `<subquery2>` ở Row 1.
- `eq_ref` cho thấy `<subquery2>` và `cities` đã join với nhau, `<subquery2>` fullscan => đây chính là strategy Materialization-Scan.

###### Rewrite SQL

```sql
explain select cities.name from cities where id IN (select city_id from populations)\G;
```

```txt
*************************** 1. row ***************************
           id: 1
  select_type: PRIMARY
        table: cities
   partitions: NULL
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 7
     filtered: 100.00
        Extra: Using where
*************************** 2. row ***************************
           id: 2
  select_type: DEPENDENT SUBQUERY
        table: populations
   partitions: NULL
         type: index_subquery
possible_keys: index_populations_on_city_id
          key: index_populations_on_city_id
      key_len: 9
          ref: func
         rows: 7
     filtered: 100.00
        Extra: Using index
2 rows in set, 1 warning (0.00 sec)
```
