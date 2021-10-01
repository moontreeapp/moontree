List append(item, List? items) {
  items = items ?? [];
  items.insert(0, item);
  return items;
}
