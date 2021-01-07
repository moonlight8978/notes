---
title: Lessons learned from Arel
code: https://github.com/moonlight8978/practice/edit/master/rails/sql-arel
---

### SQL

##### Multiple counting metadata

- `sqls/companies_counts_meta.sql`

- `app/models/company.rb`

- MySQL: Use joins to eagerload `has_one` association with scope

  - `ON` operator determine which row of `medical` will be joined with `user`. Use conditional query here to get right record of `has_one` association

- PostgreSQL:

  - `DISTINCT ON` makes life much easier

##### Sort by different column based on other column's value

- `sqls/sort_tasks.sql`

- `app/models/task.rb`

- Use CASE/WHEN statement

- If different sort direction required, multiple CASE/WHEN statements must be used

##### Sort by enum column

- `sqls/sort_users.sql`

- `app/models/user.rb`

- Use temporary mapping table to map enum to right ordered-value

- Default Arel table is `DUAL`, `DUAL` is a dummy table
  https://www.w3resource.com/sql/sql-dual-table.php#:~:text=but%20DUAL%20can%20be%20accessed,but%20you%20could%20create%20one.

- Use `Arel::Nodes::TableAlias` when using anonymous join tables

### Arel

- Arel build AST underhood

- `Arel::SelectManager` has methods to build AST tree, but `SelectManager` can become an AST node itself

- `Arel::Nodes::...` is AST node

- Use `Arel::Nodes::TableAlias` when using anonymous tables, it has `left` node which can wrap relation (can be `Arel::SelectManager`) and `#to_sql` will be delegated to. It provides `#[]` to access table attributes
