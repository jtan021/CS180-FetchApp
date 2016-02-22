#include "bst.h"
#include <iostream>
#include <map>

using namespace std;

int main()
{
    BST<int> tree;
    tree.insert(50);
    tree.insert(20);
    tree.insert(60);
    tree.insert(10);
    tree.insert(40);
    tree.insert(70);
    tree.insert(35);
    tree.insert(45);
    tree.displayMinCover();
    int buffer[2000];
    tree.findSumPath(tree.root, 145, buffer);
    std::map<int, int> m;
    tree.vertSum(tree.root,0, m);
    return 0;
}
