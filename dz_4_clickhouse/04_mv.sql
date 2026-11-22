DROP VIEW IF EXISTS takt.hw_country_hourly_mv;

DROP TABLE IF EXISTS takt.hw_country_hourly;

DROP TABLE IF EXISTS takt.hw_mv_events;

CREATE TABLE takt.hw_mv_events
(
    ended_at       DateTime('UTC'),
    country        String,
    played_seconds UInt32
)
ENGINE = MergeTree
ORDER BY ended_at;

INSERT INTO takt.hw_mv_events
SELECT ended_at, country, played_seconds
FROM takt.listening_events
WHERE ended_at >= toDateTime('2026-10-13 00:00:00', 'UTC')
  AND ended_at <  toDateTime('2026-10-27 00:00:00', 'UTC');

CREATE TABLE takt.hw_country_hourly
(
    hour            DateTime('UTC'),
    country         String,
    events          UInt64,
    events_under_20 UInt64,
    total_seconds   UInt64
)
ENGINE = SummingMergeTree(
    (events, events_under_20, total_seconds)
)
ORDER BY (hour, country);

SELECT count() AS source_events
FROM takt.hw_mv_events;

CREATE MATERIALIZED VIEW takt.hw_country_hourly_mv
TO takt.hw_country_hourly
AS
SELECT count() AS stored_rows
FROM takt.hw_country_hourly;

SELECT
    hour,
    country,
    sum(events_delta) AS events_diff,
    sum(short_delta) AS short_diff,
    sum(seconds_delta) AS seconds_diff
FROM
(
    SELECT
        toStartOfHour(ended_at) AS hour,
        country,
        toInt64(count()) AS events_delta,
        toInt64(countIf(played_seconds < 20)) AS short_delta,
        toInt64(sum(played_seconds)) AS seconds_delta
    FROM takt.hw_mv_events
    GROUP BY hour, country
    UNION ALL
    SELECT
        hour,
        country,
        -toInt64(events),
        -toInt64(events_under_20),
        -toInt64(total_seconds)
    FROM takt.hw_country_hourly
)
GROUP BY hour, country
HAVING events_diff != 0
    OR short_diff != 0
    OR seconds_diff != 0
ORDER BY hour, country;

INSERT INTO takt.hw_mv_events
    (ended_at, country, played_seconds)
VALUES
    ('2026-10-27 19:01:00', 'RU', 5),
    ('2026-10-27 19:02:00', 'RU', 19),
    ('2026-10-27 19:03:00', 'RU', 20),
    ('2026-10-27 19:04:00', 'RU', 40),
    ('2026-10-27 19:05:00', 'KZ', 25);

SELECT
    hour,
    country,
    sum(events_delta) AS events_diff,
    sum(short_delta) AS short_diff,
    sum(seconds_delta) AS seconds_diff
FROM
(
    SELECT
        toStartOfHour(ended_at) AS hour,
        country,
        toInt64(count()) AS events_delta,
        toInt64(countIf(played_seconds < 20)) AS short_delta,
        toInt64(sum(played_seconds)) AS seconds_delta
    FROM takt.hw_mv_events
    GROUP BY hour, country
    UNION ALL
    SELECT
        hour,
        country,
        -toInt64(events),
        -toInt64(events_under_20),
        -toInt64(total_seconds)
    FROM takt.hw_country_hourly
)
GROUP BY hour, country
HAVING events_diff != 0
    OR short_diff != 0
    OR seconds_diff != 0
ORDER BY hour, country;

INSERT INTO takt.hw_mv_events
    (ended_at, country, played_seconds)
VALUES
    ('2026-10-27 19:00:00', 'RU', 1),
    ('2026-10-27 20:00:00', 'RU', 10),
    ('2026-10-24 12:34:00', 'RU', 7);

SELECT
    hour,
    country,
    sum(events_delta) AS events_diff,
    sum(short_delta) AS short_diff,
    sum(seconds_delta) AS seconds_diff
FROM
(
    SELECT
        toStartOfHour(ended_at) AS hour,
        country,
        toInt64(count()) AS events_delta,
        toInt64(countIf(played_seconds < 20)) AS short_delta,
        toInt64(sum(played_seconds)) AS seconds_delta
    FROM takt.hw_mv_events
    GROUP BY hour, country
    UNION ALL
    SELECT
        hour,
        country,
        -toInt64(events),
        -toInt64(events_under_20),
        -toInt64(total_seconds)
    FROM takt.hw_country_hourly
)
GROUP BY hour, country
HAVING events_diff != 0
    OR short_diff != 0
    OR seconds_diff != 0
ORDER BY hour, country;

SELECT count() AS source_events
FROM takt.hw_mv_events;
