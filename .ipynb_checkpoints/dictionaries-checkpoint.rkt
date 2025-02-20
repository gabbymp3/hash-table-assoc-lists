#lang dssl2


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
    
    
    
    
    
###################
# Association List
###################  


    
    
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
                    break
                current = current.next
            if found == False:
                let old_head = self._head
                let new_head = _cons(key, value, old_head)
                self._head = new_head
        
        
        
        

    def del(self, key: K) -> NoneC:
        if self == None: return error('Association list is empty')
        
        if self._head.key == key:
            self._head = self._head.next
            return
        if self._head.next == None:
            return
        
        let current = self._head
        #let found = False
        while current is not None:
            # length one, key found case: 
            #if current.next == None and current.key == key:
                #self._head = None
                #found = True
               # break
            # length 2+
            if current.next == None:
                return 
            if current.next.key == key:
                #found = True
                current.next = current.next.next
                return
            current = current.next
        #if found == False:
            #return error('Key not found')
        return None
        
        

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
                
test 'AssociationList# mem? test':
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
   

    
    
test 'deletion of absent key1':
    let o = AssociationList()
    o.put(5, 'five')
    o.put(15, 'fifteen')
    o.put(25, 'twenty-five')
    o.del(25)
    assert o.mem?(5) is True
    assert o.mem?(15) is True
    assert o.mem?(25) is False    
    
test 'deletion of absent key1':
    let o = AssociationList()
    o.put(5, 'five')
    o.del(6)
    assert o.get(5) == 'five'    
    
    
test 'deletion of absent key3':
    let o = AssociationList()
    o.put(5, 'five')
    o.del(6)
    assert o.len() == 1    
    
    
    
    
################
# Hash Table
################    
    
    

class HashTable[K, V] (DICT):
    let _hash
    let _size
    let _data

    def __init__(self, nbuckets: nat?, hash: FunC[AnyC, nat?]):
        self._hash = hash
        self._data = [None; nbuckets]
        self._size = 0
        
        
    def len(self) -> nat?:
        let count = 0
        for i in range (self._data.len()):
            # each bucket is an assoc list - call .len on each.
            if self._data[i] != None:
                count = count + self._data[i].len()
        return count

        
    def mem?(self, key: K) -> bool?:
        let index = self._hash(key) % self._data.len()
        if self._data[index] is None:
            return False
            # use .mem? method from assoc list
        return self._data[index].mem?(key)
        
    
    def get(self, key: K) -> V:
        let index = self._hash(key) % self._data.len()
        if self._data[index] is None:
            return error('Key not found')
        else: return self._data[index].get(key)

        
    def put(self, key: K, value: V) -> NoneC:
        let index = self._hash(key) % self._data.len()
        if self._data[index] is None:
            self._data[index] = AssociationList()
        self._data[index].put(key, value)
        

        
    def del(self, key: K) -> NoneC:
        let index = self._hash(key) % self._data.len()
        if self._data[index] is None:
            return
        self._data[index].del(key)
        
  
        

    def __print__(self, print):
        print("#<object:HashTable  _hash=... _size=%p _data=%p>",
              self._size, self._data)




# first_char_hasher(String) -> Natural
# A simple and bad hash function that just returns the ASCII code
# of the first character.
# Useful for debugging because it's easily predictable.
def first_char_hasher(s: str?) -> int?:
    if s.len() == 0:
        return 0
    else:
        return int(s[0])
        
        
test 'HashTable# init test':
    let h
    assert_error h == HashTable(4)
    assert_error h == HashTable()

test 'HashTable# len test':
    let h = HashTable(4, first_char_hasher)
    assert h.len() == 0   
    h.put('Doechii', 'GOAT')     
    assert h.len() == 1
    h.put('Banana', 2)
    assert h.len() == 2
    assert_error h.len(1)        
        
test 'HashTable# mem? test':
    let h = HashTable(4, first_char_hasher)
    assert not h.mem?('A') 
    h.put('Beyonce', 35)
    assert h.mem?('Beyonce')
    assert not h.mem?('Chappell Roan')
    h.put('Chappell Roan', 1)
    assert h.mem?('Beyonce')
    assert h.mem?('Chappell Roan')
    h.del('Beyonce')
    assert not h.mem?('Beyonce')
    assert h.mem?('Chappell Roan')        
        
test 'HashTable# put + get test':      
    let h = HashTable(4, first_char_hasher)
    assert h.len() == 0
    h.put('Cats', 2)
    assert h.get('Cats') == 2
    assert_error h.get('Dogs')
    assert h.len() == 1
    h.put('Dogs', 1)
    assert h.len() == 2
    assert h.get('Dogs') == 1
    assert h.get('Cats') == 2
    assert_error h.get('Lizard')    
        
test 'HashTable# simple put w collision':
    let h = HashTable(4, first_char_hasher)
    h.put('Georgia', 'Peach')
    #h.__print__(println)
    assert h.len() == 1
    h.put('Connecticut', 'Nutmeg')
    h.put('California', 'Avocado')
    assert h.len() == 3
    assert h.get('Connecticut') == 'Nutmeg'
    assert h.get('California') == 'Avocado'
    
test 'HashTable# put errors':
    let h = HashTable(4, first_char_hasher)
    assert_error h.put() 
    assert_error h.put(1)
    assert_error h.put(h)
    assert_error h.put('hi')
    assert_error h.put('hi', 3, None)
    

    
test 'HashTable# delete':
    let h = HashTable(4, first_char_hasher)
    h.put('Charli xcx', 'how im feeling now')
    h.put('FKA Twigs', 'magdalene')
    h.put('Isaiah Rashad', 'The Suns Tirade')
    #h.__print__(println)
    h.del('Charli xcx')
    assert_error h.get('Charli xcx')  
    h.del('FKA Twigs')
    assert_error h.get('FKA Twigs')  
    h.del('Isaiah Rashad')
    assert_error h.get('Isaiah Rashad')    
    
 
    
    
test 'HashTable# put updates existing key':
    let h = HashTable(4, first_char_hasher)
    h.put('Paris', 'Girlfriend')
    assert h.get('Paris') == 'Girlfriend'
    h.put('Paris', 'wife')
    assert h.get('Paris') == 'wife'
    assert h.len() == 1     
    
    
test 'HashTable# deleting from empty table':
    let h = HashTable(4, first_char_hasher)
    h.del('A')    
       


test 'HashTable# different data types':
    let h = HashTable(4, make_sbox_hash())
    h.put('string', 10)
    h.put(42, 'forty-two')
    assert h.get('string') == 10
    assert h.get(42) == 'forty-two'    
    
test 'HashTable# None as key/value':
    let h = HashTable(4, make_sbox_hash())
    h.put(None, 'none_value')
    assert h.get(None) == 'none_value'
    h.put('key_with_none', None)
    assert h.get('key_with_none') == None
    
    
    
test 'HashTable# collisions using first_char_hasher':
    let h = HashTable(4, first_char_hasher)
    h.put('Apple', 'red')
    h.put('Avocado', 'green')  # collision
    assert h.get('Apple') == 'red'
    assert h.get('Avocado') == 'green'
    h.put('Banana', 'yellow')
    h.put('Blueberry', 'small')  # collision
    assert h.get('Banana') == 'yellow'
    assert h.get('Blueberry') == 'small'
    h.put('Cherry', 'red')
    assert h.get('Cherry') == 'red'
    h.del('Apple')
    assert_error h.get('Apple')
    assert h.get('Avocado') == 'green'
    
    
test 'deletion of absent key':
    let o = HashTable(10, int)
    o.put(5, 'five')
    o.put(15, 'fifteen')
    o.put(25, 'twenty-five')
    o.del(25)
    assert o.mem?(5) is True
    assert o.mem?(15) is True
    assert o.mem?(25) is False
    let a = HashTable(10, int)
    a.put(5, 'five')
    a.del(6)
    assert a.get(5) == 'five'
    let e = HashTable(10, int)
    e.put(5, 'five')
    e.del(6)
    assert e.len() == 1
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


def compose_phrasebook(d: DICT!) -> DICT?:
    d.put('Bom dia', ['Good morning', 'bom dee-ya'])
    d.put('Tudo bem?', ['All good?', 'tu-du baim?'])
    d.put('Agua', ['Water', 'ah-gwah'])
    d.put('Sapato', ['Shoe', 'sah-pah-tu'])
    d.put('Pao de Queijo', ['Cheese bread', 'pown-deh-kay-zho'])
    return d
    

test "AssociationList phrasebook":
    let a = AssociationList()
    compose_phrasebook(a)
    assert a.get('Pao de Queijo')[1] == 'pown-deh-kay-zho'


test "HashTable phrasebook":
    let h = HashTable(10, make_sbox_hash())
    compose_phrasebook(h)
    assert h.get('Agua')[1] == 'ah-gwah'

    