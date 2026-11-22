# Ключ сортировки: ответы и планы

За 24 октября я сравнил два отчета: только DE и все страны. Каждый запускал на обеих таблицах. [Все четыре запроса](../02_order_by.sql) подписаны так же, как здесь. Чтение взял у обычного `SELECT`, план снял отдельно

## Подготовка

| table | active_parts | events |
| --- | --- | --- |
| hw_events_country | 1 | 10000000 |
| hw_events_time | 1 | 10000000 |

```sql
CREATE TABLE takt.hw_events_time
(
    `ended_at` DateTime('UTC') CODEC(Delta(4), ZSTD(1)),
    `user_id` UInt64,
    `track_id` UInt64,
    `country` String,
    `platform` String,
    `app_version` String,
    `played_seconds` UInt32,
    `track_seconds` UInt32
)
ENGINE = MergeTree
ORDER BY ended_at
SETTINGS index_granularity = 8192, index_granularity_bytes = 0
```

```sql
CREATE TABLE takt.hw_events_country
(
    `ended_at` DateTime('UTC') CODEC(Delta(4), ZSTD(1)),
    `user_id` UInt64,
    `track_id` UInt64,
    `country` String,
    `platform` String,
    `app_version` String,
    `played_seconds` UInt32,
    `track_seconds` UInt32
)
ENGINE = MergeTree
ORDER BY (country, ended_at)
SETTINGS index_granularity = 8192, index_granularity_bytes = 0
```

## DE-time

[SQL](../02_order_by.sql#L49) · `query_id` обычного SELECT: `1a7f8e57-36ea-4fe2-80ac-47f020735b94`

| country | events_total | events_under_20 | under_20_percent |
| --- | --- | --- | --- |
| DE | 59423 | 14833 | 24.96 |

Запрос прочитал 835584 строки (15040512 байт)

```text
Expression ((Project names + (Before ORDER BY + Projection) [lifted up part]))
  Sorting (Sorting for ORDER BY)
    Expression ((Before ORDER BY + Projection))
      Aggregating
        Expression (Before GROUP BY)
          Filter ((WHERE + Change column names to column identifiers))
            ReadFromMergeTree (takt.hw_events_time)
            Indexes:
              PrimaryKey
                Keys:
                  ended_at
                Condition: and((ended_at in (-Inf, 1792886399]), (ended_at in [1792800000, +Inf)))
                Parts: 1/1
                Granules: 102/1221
                Search Algorithm: binary search
                Ranges: 1
```

## DE-country

[SQL](../02_order_by.sql#L68) · `query_id` обычного SELECT: `7d63e4e5-b8d8-4e26-bb26-685fbe47ec2b`

| country | events_total | events_under_20 | under_20_percent |
| --- | --- | --- | --- |
| DE | 59423 | 14833 | 24.96 |

Запрос прочитал 65536 строк (1179648 байт)

```text
Expression ((Project names + (Before ORDER BY + Projection) [lifted up part]))
  Sorting (Sorting for ORDER BY)
    Expression ((Before ORDER BY + Projection))
      Aggregating
        Expression (Before GROUP BY)
          Filter ((WHERE + Change column names to column identifiers))
            ReadFromMergeTree (takt.hw_events_country)
            Indexes:
              PrimaryKey
                Keys:
                  country
                  ended_at
                Condition: and((country in ['DE', 'DE']), and((ended_at in (-Inf, 1792886399]), (ended_at in [1792800000, +Inf))))
                Parts: 1/1
                Granules: 8/1221
                Search Algorithm: binary search
                Ranges: 1
```

## all-time

[SQL](../02_order_by.sql#L87) · `query_id` обычного SELECT: `b6ad97a0-112f-4875-822e-e4e2db96806a`

| country | events_total | events_under_20 | under_20_percent |
| --- | --- | --- | --- |
| BR | 34608 | 8771 | 25.34 |
| BY | 66713 | 16693 | 25.02 |
| DE | 59423 | 14833 | 24.96 |
| KZ | 97107 | 23856 | 24.57 |
| RU | 451255 | 112679 | 24.97 |
| TR | 66135 | 16438 | 24.86 |
| US | 50128 | 12690 | 25.32 |

Запрос прочитал 835584 строки (15040512 байт)

```text
Expression ((Project names + (Before ORDER BY + Projection) [lifted up part]))
  Sorting (Sorting for ORDER BY)
    Expression ((Before ORDER BY + Projection))
      Aggregating
        Expression (Before GROUP BY)
          Filter ((WHERE + Change column names to column identifiers))
            ReadFromMergeTree (takt.hw_events_time)
            Indexes:
              PrimaryKey
                Keys:
                  ended_at
                Condition: and((ended_at in (-Inf, 1792886399]), (ended_at in [1792800000, +Inf)))
                Parts: 1/1
                Granules: 102/1221
                Search Algorithm: binary search
                Ranges: 1
```

## all-country

[SQL](../02_order_by.sql#L105) · `query_id` обычного SELECT: `55bb536a-0706-4fdc-9283-c6d60e7d90df`

| country | events_total | events_under_20 | under_20_percent |
| --- | --- | --- | --- |
| BR | 34608 | 8771 | 25.34 |
| BY | 66713 | 16693 | 25.02 |
| DE | 59423 | 14833 | 24.96 |
| KZ | 97107 | 23856 | 24.57 |
| RU | 451255 | 112679 | 24.97 |
| TR | 66135 | 16438 | 24.86 |
| US | 50128 | 12690 | 25.32 |

Запрос прочитал 931456 строк (16766208 байт)

```text
Expression ((Project names + (Before ORDER BY + Projection) [lifted up part]))
  Sorting (Sorting for ORDER BY)
    Expression ((Before ORDER BY + Projection))
      Aggregating
        Expression (Before GROUP BY)
          Filter ((WHERE + Change column names to column identifiers))
            ReadFromMergeTree (takt.hw_events_country)
            Indexes:
              PrimaryKey
                Keys:
                  ended_at
                Condition: and((ended_at in (-Inf, 1792886399]), (ended_at in [1792800000, +Inf)))
                Parts: 1/1
                Granules: 114/1221
                Search Algorithm: generic exclusion search
                Ranges: 14
```
