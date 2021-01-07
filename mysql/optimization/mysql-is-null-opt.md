---
source code: N/A
---

MySQL có thể tối ưu câu `col_name IS NULL` tương tự như những truy vấn với `col_name = constant_value`

MySQL có thể sử dụng index và range để query `IS NULL`.

##### Khi nào IS NULL không được tối ưu.

- Khi 1 trường trong DB được định nghĩa là `NOT NULL` nhưng lại sử dụng `IS NULL` trong query.
-
