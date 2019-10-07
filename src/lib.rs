#[macro_use]
extern crate rutie;
#[macro_use]
extern crate lazy_static;

use rutie::{AnyObject, Boolean, Fixnum, Module, NilClass, Object, VM, Class};
use std::ops::{Deref, DerefMut};

class!(BitArray);

pub struct BitArrayStore {
    store: Vec<bool>,
}

impl BitArrayStore {
    fn new(size: usize) -> Self {
        BitArrayStore {
            store: vec![false; size],
        }
    }
}

impl Deref for BitArrayStore {
    type Target = Vec<bool>;

    fn deref(&self) -> &Vec<bool> {
        &self.store
    }
}

impl DerefMut for BitArrayStore {
    fn deref_mut(&mut self) -> &mut Vec<bool> {
        &mut self.store
    }
}

wrappable_struct!(BitArrayStore, BitArrayStoreWrapper, BIT_ARRAY_STORE_WRAPPER);

fn bounds_checked_index(len: usize, index: i64) -> Option<usize> {
    if index < 0 {
      let adjusted_index = (len as i64) + index;
      if adjusted_index < 0 {
        return None;
      }
      return Some(adjusted_index as usize);
    }

    if index >= (len as i64) {
      return None;
    }
    Some(index as usize)
}

methods!(
    BitArray,
    itself,

    fn pub_self_new(ruby_size: Fixnum) -> AnyObject {
      if let Err(e) = ruby_size {
        VM::raise_ex(e);
        return NilClass::new().into();
      }
      let size = ruby_size.unwrap().to_i64();
      if size < 0 {
        VM::raise(Class::from_existing("ArgumentError"), "negative array size")
      }
      let store = BitArrayStore::new(size as usize);

      Module::from_existing("RustyBitArray")
          .get_nested_class("BitArray")
          .wrap_data(store, &*BIT_ARRAY_STORE_WRAPPER)
    }

    fn pub_get(ruby_n: Fixnum) -> AnyObject {
      if let Err(e) = ruby_n {
          VM::raise_ex(e);
          return NilClass::new().into();
      }

      let n = ruby_n.unwrap().to_i64();
      let store = itself.get_data(&*BIT_ARRAY_STORE_WRAPPER);

      match bounds_checked_index(store.len(), n) {
          Some(n) => Boolean::new(store[n]).into(),
          None => NilClass::new().into(),
      }
    }

    fn pub_set(ruby_n: Fixnum, object: AnyObject) -> AnyObject {
      if let Err(e) = ruby_n {
          VM::raise_ex(e);
          return NilClass::new().into();
      }

      let n = ruby_n.unwrap().to_i64();
      let store = itself.get_data_mut(&*BIT_ARRAY_STORE_WRAPPER);
      let value = object
          .map(|obj| !obj.value().is_nil() && !obj.value().is_false())
          .unwrap_or(false);

      match bounds_checked_index(store.len(), n) {
          Some(n) => store[n] = value,
          None => VM::raise(Class::from_existing("IndexError"), "Access out of bounds"),
      }

      Boolean::new(value).into()
    }

    fn pub_length() -> Fixnum {
      let len = itself.get_data(&*BIT_ARRAY_STORE_WRAPPER).len() as i64;
      Fixnum::new(len)
    }
);

#[allow(non_snake_case)]
#[no_mangle]
pub extern "C" fn Init_bit_array() {
    let mut rusty_bit_array_mod = Module::from_existing("RustyBitArray");
    rusty_bit_array_mod.define(|itself| {
        let mut bit_array_class = itself.define_nested_class("BitArray", None);
        bit_array_class.def_self("new", pub_self_new);
        bit_array_class.def("[]", pub_get);
        bit_array_class.def("[]=", pub_set);
        bit_array_class.def("length", pub_length);
        bit_array_class.def("size", pub_length);
    });
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
