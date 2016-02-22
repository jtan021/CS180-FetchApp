#ifndef bst_H
#define bst_H

#include <cassert>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string>
#include <sstream>
#include <map>
#include <list>
#include <queue>
#include <math.h>
#include <algorithm>
using namespace std;
#define nil 0

// #define Value int // restore for testing.
template < typename Value >
class BST {
    class Node { // binary tree node
        public:
        Node* left;
        Node* right;
        Value value;
        Node( const Value v = Value() )
        : left(nil), right(nil), value(v)
        {}
        Value& content() { return value; }
        bool isInternal() { return left != nil && right != nil; } //If has 2 children, return true. Else return false.
        bool isExternal() { return left != nil || right != nil; } //If has a child, return true. Else return false.
        bool isLeaf() { return left == nil && right == nil; }     //If has no child, returns true. Else returns false.
        
        int height() {
            int R_ct = 0;
            int L_ct = 0;
            if(isLeaf())
                return 1;
            if(left != nil)
                L_ct = left->height();
            if(right != nil)
                R_ct = right->height();
            return 1 + max(L_ct,R_ct);
        }
        
        int size() {
            if(left == nil)
            {
                if(right == nil)
                {
                    return 1;
                }
                return right->size() + 1;
            }
            if(right == nil)
            {
                if(left == nil)
                {
                    return 1;
                }
                return left->size() + 1;
            }
            return left->size() + 1 + right->size();
        }
    }; // Node
    // const Node* nil; // later nil will point to a sentinel node.

    public:
    Node* root;
    int count;
    int size() {
        if(root == nil)
            return 0;
        // cerr << "Size is working" << endl;
        return root->size();
    }
    
    bool empty() { return size() == 0; }
    
    void print_node( const Node* n ) {
        cout << n->value << endl;
    }
    
    void height() {
        cout << root->height();
    }

    bool search ( Value x ) {
        Node *curr = root;
        while(curr != NULL)
        {
            if(curr->value == x)
                return true;
            if(x > curr->value)
                curr = curr->right;
            else
                curr = curr->left;
        }
        return false;
        // search for a Value in the BST and return true iff it was found.
        // FILL +IN
    }
    
    void PRE_Output(Node* n) const
    {
        if(n != NULL)
        {
            cout << n->value << endl;
            PRE_Output(n->left);
            PRE_Output(n->right);
        }
    }
    
    void preorder() const {
        Node* head = root;
        PRE_Output(head);
        // Traverse and print the tree one Value per line in preorder.
        // FILL IN
    }
    
    void POST_Output(Node* n) const
    {
        if(n != NULL)
        {
            POST_Output(n->left);
            POST_Output(n->right);
            cout << n->value << endl;
        }
    }
    
    void postorder() const {
        Node* head = root;
        POST_Output(head);
    }
    
    void IO_Output(Node* n) const
    {
        if(n != NULL)
        {
            IO_Output(n->left);
            cout << n->value << endl;
            IO_Output(n->right);
        }
    }
    
    void inorder()const {
        Node* head = root;
        IO_Output(head);
    }
    
    void set_inorder(Node* curr, queue<Value>& list) 
    {
        if(curr != NULL)
        {
            set_inorder(curr->left, list);
            list.push(curr->value);
            set_inorder(curr->right, list);
        }
    }

    Value& operator[] (int n) {
        Node* curr = root;
        queue<Value> list;
        set_inorder(curr, list);
        int sz = size()-1;
        if(n > sz || n < 0)
        {
            cout << "ERROR: Out of bounds.\n";
            exit(-1);
        }
        int count = 0;
        if(count == n)
        {
            Node* found = new Node(list.front());
            return found->value;
        }
        while(count != n)
        {
            list.pop();
            ++count;
        }
        Node* found = new Node(list.front());
        return found->value;
    }

    BST() : root(nil), count(0) {}
    void insert( Value X ) { root = insert( X, root ); }
    Node* insert( Value X, Node* T ) {
        // The normal binary-tree insertion procedure ...
        if ( T == nil ) {
            T = new Node( X ); // the only place that T gets updated.
        } else if ( X < T->value ) {
            T->left = insert( X, T->left );
        } else if ( X > T->value ) {
            T->right = insert( X, T->right );
        } else {
            T->value = X;
        }
        // later, rebalancing code will be installed here
        return T;
    }
    
    void remove( Value X ) { root = remove( X, root ); }
    Node* remove( Value X, Node*& T ) {
        if ( T != nil ) {
            if ( X > T->value ) {
                T->right = remove( X, T->right );
            } else if ( X < T->value ) {
                T->left = remove( X, T->left );
            } else { // X == T->value
                if ( T->right != nil ) {
                    Node* x = T->right;
                    while ( x->left != nil ) x = x->left;
                    T->value = x->value; // successor’s value
                    T->right = remove( T->value, T->right );
                } else if ( T->left != nil ) {
                    Node* x = T->left;
                    while ( x->right != nil ) x = x->right;
                    T->value = x->value; // predecessor’s value
                    T->left = remove( T->value, T->left );
                } else { // *T is external
                    delete T;
                    T = nil; // the only updating of T
                }
            }
        }
        // later, rebalancing code will be installed here
        return T;
    }
    
    void okay( ) { okay( root ); }
    
    void okay( Node* T ) {
        // diagnostic code can be installed here
        return;
    }
    
    void minCoverRecursion(Node* curr, list<Value> &L)
    {
        if(!curr->isLeaf() && curr != root)
        {
            L.push_back(curr->value);
        }
        if(curr->left != nil)
            minCoverRecursion(curr->left, L);
        if(curr->right != nil)
            minCoverRecursion(curr->right, L);
    }
    
    void minCover()
    {
        Node* curr = root;
        list<int> L;
        minCoverRecursion(curr, L);
    }
    
    void displayMinCover()
    {
        cout << "Part 1" << endl;
        Node* curr = root;
        list<int> L;
        minCoverRecursion(curr, L);
        L.sort();
        list<int>::iterator j;
        j = L.begin();
        while(j != L.end())
        {
            cout << *j << " ";
            j++;
        }
        cout << endl;
        cout << L.size() << endl;
    }

    bool PathSum(Node* n, int sum)
    {
        if(n == nil)
        {
            return (sum == 0);
        }
        else
        {
            bool ans = 0;
            int subSum = sum - n->value;
            if(subSum == 0 && n->left == nil && n->right == nil)
                return 1;
            
            if(n->left != nil)
                ans = ans || PathSum(n->left, subSum);
            if(n->right != nil)
                ans = ans || PathSum(n->right, subSum);
                
            return ans;
        }
    }
    
    void printPath(int buffer[], int path)
    {
        // cout << "hello";
        list<int> L;
        for(int i = 0; i < path; i++)
            L.push_back(buffer[i]);
        L.sort();
        list<int>::iterator j;
        j = L.begin();
        while(j != L.end())
        {
            cout << *j << " ";
            j++;
        }
        cout << endl;
    }
    
    void findSumPathRecursion(Node *n, int currSum, int subSum, int path, int buffer[])
    {
        if(n == nil)
        {
            return;
        }
        buffer[path] = n->value;
        path++;
        currSum += n->value;
        // for(int i = 0; buffer[i] != '\0'; i++)
        //     cout << "Buffer here: " << buffer[i] << " ";
        // cout << endl;
        if(n->left == nil && n->right == nil && currSum == subSum)
        {
            printPath(buffer, path);
            // for(int i = 0; i < path; i++)
            //     cout << buffer[i] << " ";
            // cout << endl;
            return;
        }
        if(n->left != nil)
            findSumPathRecursion(n->left, currSum, subSum, path, buffer);
        if(n->right != nil)
            findSumPathRecursion(n->right, currSum, subSum, path, buffer);
        // currSum -= n->value;
    }

    void findSumPath(Node* n, int sum, int buffer[])
    {
        cout << "Part 2\n";
        int path = 0;
        if(PathSum(n, sum))
        {
            findSumPathRecursion(n, 0, sum, path, buffer);
        }
        else
        {
            cout << "0\n";
            return;
        }
    }
    
    void vertSumRecursion(Node* node, int hd, std::map<int, int> &m)
    {
        if(root == nil)
            return;
        m[hd] += node->value;
        if(node->left != nil)
            vertSumRecursion(node->left, hd-1, m);
        if(node->right != nil)
            vertSumRecursion(node->right, hd+1, m);
    }
    
    void vertSum(Node* node, int hd, std::map<int, int> &m)
    {
        vertSumRecursion(node, hd, m);
        cout << "Part 3\n";
        for(std::map<int,int>::iterator it=m.begin(); it!=m.end(); ++it)
        {
            cout << it->second << " ";
        }
        cout << endl;
    }
}; 
#endif
