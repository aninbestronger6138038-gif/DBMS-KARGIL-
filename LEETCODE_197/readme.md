LEETCODE 197
QUESTION:
Table: Weather

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| recordDate    | date    |
| temperature   | int     |
+---------------+---------+
id is the column with unique values for this table.
There are no different rows with the same recordDate.
This table contains information about the temperature on a certain day.
 

Write a solution to find all dates' id with higher temperatures compared to its previous dates (yesterday).

Return the result table in any order.

SOURCE CODE:

SELECT w1.id

FROM Weather w1

JOIN Weather w2 ON DATE(w1.recordDate) = DATE(w2.recordDate) + INTERVAL 1 DAY 

WHERE w1.temperature > w2.temperature;


