#lang dssl2

let eight_principles = ["Know your rights.",
        "Acknowledge your sources.",
        "Protect your work.",
        "Avoid suspicion.",
        "Do your own work.",
        "Never falsify a record or permit another person to do so.",
        "Never fabricate data, citations, or experimental results.",
        "Always tell the truth when discussing your work with your instructor."]

# HW3: Dictionaries

import sbox_hash

# A signature for the dictionary ADT. The contract parameters `K` and
# `V` are the key and value types of the dictionary, respectively.
interface DICT[K, V]:
    # Returns the number of key-value pairs in the dictionary.
    def len(self) -> nat?
    # Is the given key mapped by the dictionary?
    # Notation: `key` is the name of the parameter. `K` is its contract.
    def mem?(self, key: K) -> bool?
    # Gets the value associated with the given key; calls `error` if the
    # key is not present.
    def get(self, key: K) -> V
    # Modifies the dictionary to associate the given key and value. If the
    # key already exists, its value is replaced.
    def put(self, key: K, value: V) -> NoneC
    # Modifes the dictionary by deleting the association of the given key.
    def del(self, key: K) -> NoneC
    # The following method allows dictionaries to be printed
    def __print__(self, print)


# association list node struct
struct _cons:
    let key
    let value
    let next: OrC(_cons?, NoneC)


    
    
class AssociationList[K, V] (DICT):

    let _head


    def __init__(self):
        let _head = None
        self._head = _head
        


    def len(self) -> nat?:
        let count = 0
        let current = self._head
        while current is not None:
            count = count + 1
            current = current.next
        return count        
        
        
        
        
    def mem?(self, key: K) -> bool?:
        let found = False
        let current = self._head
        while current is not None:
            if current.key == key:
                found = True
            current = current.next
        return found

    
    def get(self, key: K) -> V:
        let found = False
        let current = self._head
        while current is not None:
            if current.key == key:
                return current.value
                found = True
            current = current.next
        if found == False:
            return error('Key not found')
        
    def put(self, key: K, value: V) -> NoneC:
        let found = False
        # make head of empty assoc. list
        if self._head == None:
            self._head = _cons(key, value, None)
            found = True
        # if not empty, linear search and update if exists. If not, make new head.
        else:
            let current = self._head
            while current is not None:
                if current.key == key:
                    current.value = value
                    found = True
                current = current.next
            if found == False:
                let old_head = self._head
                let new_head = _cons(key, value, old_head)
                self._head = new_head
        
        
        
        

    def del(self, key: K) -> NoneC:
        if self == None: return error('Association list is empty')
        let current = self._head
        let found = False
        while current is not None:
            # length one, key found case: 
            if current.next == None and current.key == key:
                self._head = None
                found = True
            # length 2+
            elif current.next.key == key:
                found = True
                current.next = current.next.next
            current = current.next
        if found == False:
            return error('Key not found')
        
        

    # See above.
    def __print__(self, print):
        print("#<object:AssociationList head=%p>", self._head)

        
#___________________________________________________

        
test 'AssociationList# init test':
    let a
    let b
    assert_error a == AssociationList(1)
    assert_error b == AssociationList(a)


test 'AssociationList# len test':
    let a = AssociationList()
    assert a.len() == 0   
    a.put(1, 'a')     
    assert a.len() == 1
    a.put(2, 'b')
    assert a.len() == 2
    assert_error a.len(1)
    assert_error a.len(a)
                
test 'AssociationList# mem test':
    let a = AssociationList()
    a.put(1,'a')
    assert a.mem?(1)
    assert_error a.mem?()
    assert not a.mem?('a')
    a.put(2,'b')
    assert a.mem?(1)
    assert a.mem?(2)
    assert not a.mem?(3)
    a.del(1)
    assert not a.mem?(1)
    assert a.mem?(2)
        
test 'AssociationList# put + get test':      
    let a = AssociationList()
    assert a.len() == 0
    a.put('hi', 2)
    assert a.get('hi') == 2
    assert_error a.get()
    assert_error a.get('hello')
    assert a.len() == 1
    a.put('hey', 3)
    assert a.len() == 2
    assert a.get('hey') == 3
    assert a.get('hi') == 2
    assert_error a.get(3)
    #a.__print__(println)
    assert a.mem?('hi') == True
    assert a.mem?('hey') == True
    assert a.mem?('dog') == False
        
test 'AssociationList# put errors':
    let a = AssociationList()
    assert_error a.put()
    assert_error a.put(1)
    assert_error a.put(a)
    assert_error a.put('hi')
    assert_error a.put('hi', 3, None)
        
test 'AssociationList# delete':
    let a = AssociationList()
    a.put(1, 'a')
    a.put(2, 'b')
    a.put(3, 'c')
    #a.__print__(println)
    a.del(1)
    assert_error a.get(1)
    #a.__print__(println)
    a.del(2)
    assert_error a.get(2)
    #a.__print__(println)
    a.del(3)
    assert_error a.get(3)
    #a.__print__(println)
        
        
test 'AssociationList# put updates existing key':
    let a = AssociationList()
    a.put(1, 'a')
    assert a.get(1) == 'a'
    a.put(1, 'updated')
    assert a.get(1) == 'updated'
    assert a.len() == 1       
        
        
test 'AssociationList# deleting from empty list':
    let a = AssociationList()
    assert_error a.del(1)
            
        
test 'AssociationList# diff data types':
    let a = AssociationList()
    a.put('string', 10)
    a.put(42, 'forty-two')
    assert a.get('string') == 10
    assert a.get(42) == 'forty-two'    

    

test 'AssociationList# None as key/value':
    let a = AssociationList()
    a.put(None, 'none_value')
    assert a.get(None) == 'none_value'
    a.put('key_with_none', None)
    assert a.get('key_with_none') == None    
    
    
    
test 'yOu nEeD MorE tEsTs':
    let a = AssociationList()
    assert not a.mem?('hello')
    a.put('hello', 5)
    assert a.len() == 1
    assert a.mem?('hello')
    assert a.get('hello') == 5


class HashTable[K, V] (DICT):
    let _hash
    let _size
    let _data

    def __init__(self, nbuckets: nat?, hash: FunC[AnyC, nat?]):
        self._hash = hash
        self._data = [None; nbuckets]
        self._size = 0
        
        
    def len(self) -> nat?:
        pass

        
    def mem?(self, key: K) -> bool?:
        pass
        
    
    def get(self, key: K) -> V:
        pass
        
    def put(self, key: K, value: V) -> NoneC:
        
        pass
        
    def del(self, key: K) -> NoneC:
        pass     
        
        
        
        
        
        
        
    #   ^ ADD YOUR WORK HERE

    # This avoids trying to print the hash function, since it's not really
    # printable and isn’t useful to see anyway:
    def __print__(self, print):
        print("#<object:HashTable  _hash=... _size=%p _data=%p>",
              self._size, self._data)

    # Other methods you may need can go here.


# first_char_hasher(String) -> Natural
# A simple and bad hash function that just returns the ASCII code
# of the first character.
# Useful for debugging because it's easily predictable.
def first_char_hasher(s: str?) -> int?:
    if s.len() == 0:
        return 0
    else:
        return int(s[0])

test 'yOu nEeD MorE tEsTs, part 2':
    let h = HashTable(10, make_sbox_hash())
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    assert h.mem?('hello')
    assert h.get('hello') == 5


def compose_phrasebook(d: DICT!) -> DICT?:
    pass
#   ^ ADD YOUR WORK HERE

test "AssociationList phrasebook":
    pass

test "HashTable phrasebook":
    pass
