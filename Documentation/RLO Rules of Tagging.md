# REED London Tagging Protocols

When tagging semantics (whether regular or entity), tag the first reference in a document (or excerpt) in the English (not in a transcription in another language). If there are multiple records or excerpts, tag the first reference in each.

Make sure to tag a reference that invokes that person or place, rather than something adjacent to them (e.g., don't tag the Mayor of London in 'the mayor's servants' or Queen Elizabeth in 'the twenty-second year of the reign of Elizabeth'. 

Tag dates when they are explicit and implicit (e.g., 'Thursday next following' should be tagged with date if that can be calculated; 'Shrovetide' should be tagged with date, since that is a stable one.

Tag amounts, and add currency attribute if possible. Do not try to convert £ to pence, or anything more specific. 

When tagging entities, first option is if there is already a CWRC entity (or it is important to create one). Second option is Wikidata. Continue from there. 

Tag a person or place or organization or date in a note as well as in the text (since a note is an annotation that might be detached from the text.)

Until the eventName element is created, use <name type="event">


Capturing notes for Aragon cluster:
[Court of Aldermen, Reportory 1](https://cwrc.ca/islandora/object/reed%3Adb52b946-bdeb-4c5a-bd84-4c41543a46dc)

[Royal Entry Event Object](https://cwrc.ca/islandora/object/reed%3A7255ec4e-ba99-48fa-bf99-89c6afe6e7d9)

[Armourers and Brasiers' Wardens Accounts 1501-3](https://cwrc.ca/islandora/object/reed%3Ab68bb7d8-8dde-4d6a-8ab0-ee42f53c95ef)

[Bakers' Audit Book, 1499-1501](https://cwrc.ca/islandora/object/reed%3Ae9b9d44c-6a07-47ad-b39e-038adb8c9637)

There's something wrong with Brewers' accounts: https://cwrc.ca/islandora/object/reed%3A48b53094-d473-4912-869d-e30fecc51670
