# Work Flow

## Steps

```
DAY=
MOTH=
DATE=2017-$MOTH-$DAY
```

0. Start VAST (and perhaps some continuous query with ...)
1. Import blacklist data filtered by "spam" type           `./import_blacklist.sh $DATE)`
2. Import honeypots, filters by ASNs in blacklists         `./filtered_import_honeypot.sh $DATE)`
3. Make some continuous query                              `vast export bro -c "source_as == $SUSPICIOUS")`
4. Import mrt data, filtered by IPs in conn logs           `./filtered_import_mrt.sh $DATE)`
5. Statistics
    - Conn hosts:                                            `vast export bro "&type == \"bro::conn\"" | bro-cut -d id.orig_h | sort -u | wc -l`
    - ASNs occurrences:                                      `vast export bro "..." | bro-cut ...`
    - ASNS that have a withdrawl and lifetime:               `./query_find_withdrawn.sh`
    - Find MOAs:                                             `./query_find_multipleorigins.sh`
    - Find more specific announcements                       `./query_find_morespecific.sh`
    - Find something with time                               `./query_find_ephemeralannouncements.sh`

## BASH panes

| Pane |           |                      |                      |                     |               |
|------|-----------|----------------------|----------------------|---------------------|---------------|
| A    | 0) VAST   | 1) import bl + query |                      |                     |               |
| B    | 0) query? |                      | 2) import hp + query |                     |               |
| C    |           |                      |                      | 3) continuous query |               |
| D    |           |                      |                      | 4) import MRT data  | 5) statistics |

## Notes
* Maybe we could interleave the some statistics queries with the MRT import, which takes a while ...
* Not all people will want to stick around for all the imports
    - What can we show without all the steps?
    - Maybe a local (not server) VAST instance with a small dataset for some queries?

## TODOs
- [ ] Write continuous query (once we have more knowledge about the data)
- [x] Draft for demo plan
- [ ] Script to sift through data and find a dataset
- [ ] Settle on a dataset & adjust scripts
- [ ] Fix work flow
- [ ] Fix scripts to the data?

