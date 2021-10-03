abstract class Tree<T> {
  T? get value;
  int get frequency;
  Tree<T>? get left;
  Tree<T>? get right;
  bool get isNode;
  bool get isLeaf;
}

class Leaf<T> implements Tree<T> {
  const Leaf({
    required int frequency,
    required T value,
  })  : _frequency = frequency,
        _value = value;

  final int _frequency;
  final T _value;

  @override
  Tree<T>? get left => null;

  @override
  Tree<T>? get right => null;

  @override
  int get frequency => _frequency;

  @override
  bool get isLeaf => true;

  @override
  bool get isNode => false;

  @override
  T get value => _value;

  @override
  String toString() {
    return '($value, $frequency)';
  }
}

class Node<T> implements Tree<T> {
  const Node({required Tree<T> left, required Tree<T> right})
      : _left = left,
        _right = right;

  final Tree<T> _left;
  final Tree<T> _right;

  @override
  Tree<T> get left => _left;

  @override
  Tree<T> get right => _right;

  @override
  int get frequency => _left.frequency + _right.frequency;

  @override
  bool get isLeaf => false;

  @override
  bool get isNode => true;

  @override
  T? get value => null;

  @override
  String toString() {
    return '($frequency)';
  }
}

Map<T, List<int>> treeAsTable<T>(Tree<T> tree) {
  final result = <T, List<int>>{};

  void treeAsTableHelper(Tree<T> tree, List<int> prefix) {
    if (tree is Leaf<T>) {
      result[tree.value] = prefix;
    } else if (tree is Node<T>) {
      treeAsTableHelper(tree.left, List.of(prefix)..add(0));
      treeAsTableHelper(tree.right, List.of(prefix)..add(1));
    }
  }

  treeAsTableHelper(tree, []);
  return result;
}

Tree<int> merge(List<Tree<int>> trees, List<Leaf<int>> leafs) {
  while (leafs.isNotEmpty) {
    if (trees.isEmpty) {
      if (leafs.length > 2) {
        final left = leafs.removeAt(0);
        final right = leafs.removeAt(0);
        assert(left != right);
        final node = Node<int>(left: left, right: right);
        trees.add(node);
      } else {
        trees.addAll(leafs);
        leafs.clear();
      }
    } else {
      final minimumTreeIndex = minimumIndex(trees);
      const firstMinimumLeafIndex = 0;
      final secondMinimumLeafIndex =
          leafs.length > 1 ? 1 : firstMinimumLeafIndex;

      final hasSecondLeafSmallerThanNode =
          firstMinimumLeafIndex != secondMinimumLeafIndex &&
              leafs[secondMinimumLeafIndex].frequency <
                  trees[minimumTreeIndex].frequency;
      if (hasSecondLeafSmallerThanNode) {
        final left = leafs[firstMinimumLeafIndex];
        final right = leafs[secondMinimumLeafIndex];
        final node = Node<int>(left: left, right: right);
        trees.add(node);
        assert(firstMinimumLeafIndex == 0);
        assert(secondMinimumLeafIndex == 1);
        leafs.removeRange(firstMinimumLeafIndex, secondMinimumLeafIndex + 1);
      } else {
        final tree = trees[minimumTreeIndex];
        final leaf = leafs[firstMinimumLeafIndex];
        late Tree<int> left;
        late Tree<int> right;
        if (tree.frequency <= leaf.frequency) {
          left = tree;
          right = leaf;
        } else {
          left = leaf;
          right = tree;
        }
        final node = Node<int>(left: left, right: right);
        trees
          ..add(node)
          ..removeAt(minimumTreeIndex);
        leafs.removeAt(firstMinimumLeafIndex);
      }
    }
  }
  while (trees.length > 1) {
    final firstSmaller = minimumIndex(trees);
    final secondSmaller = minimumIndex(trees, firstSmaller + 1);
    final node =
        Node<int>(left: trees[firstSmaller], right: trees[secondSmaller]);
    trees
      ..removeAt(secondSmaller)
      ..removeAt(firstSmaller)
      ..add(node);
  }
  assert(trees.length == 1);
  return trees.first;
}

int minimumIndex<T>(List<Tree<T>> trees, [int fromIndex = 0]) {
  assert(trees.isNotEmpty);
  var minimumIndex = fromIndex;
  for (var i = fromIndex + 1; i < trees.length; i++) {
    if (trees[i].frequency < trees[minimumIndex].frequency) {
      minimumIndex = i;
    }
  }
  return minimumIndex;
}
