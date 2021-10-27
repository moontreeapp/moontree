## 4.0.1

- Make sure hive keys are deserialized as strings

## 4.0.0

- Add 'Loaded' change type that is triggered on load
- Change changes to `batchedChanges` and add `changes` stream
- Preserve type information for change streams

## 3.1.0

- Add 'clear' to indexes

## 3.0.0

- Remove source from Reservoir constructor
- Call `setSource` to set the source at any time
- Fix de-indexing when saving a record

## 2.1.0

- Lazy-load boxes in HiveSource
 
## 2.0.0

- Type safe Keys and Indexes

## 1.4.0

- Fix saveAll / removeAll:
  - await changes
  - publish changes
  - don't publish zero-length changes

## 1.3.0

- Export MapSource class
- Add example

## 1.2.0

- Export Change and Source classes

## 1.1.0

- Fix box not initialized error

## 1.0.0

- Initial version.
