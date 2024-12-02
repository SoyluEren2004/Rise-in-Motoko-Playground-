import List "mo:base/List";
import Option "mo:base/Option";
import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";

actor Foodlist {

  /**
   * Types
   */

  // The type of a superhero identifier.
  public type FoodId = Nat32;

  // The type of a superhero.
  public type Food = {
    name : Text;
    content:Text;
    price : Nat32;
    size : List.List<Text>;
  };

  /**
   * Application State
   */

  // The next available superhero identifier.
  private stable var next : FoodId = 0;

  private stable var wallet : Nat32 = 0;

  // The superhero data store.
  private stable var foods : Trie.Trie<FoodId, Food> = Trie.empty();

  /**
   * High-Level API
   */

  // Create a superhero.
  public func create(food : Food) : async FoodId {
    let foodId = next;
    next += 1;
    foods := Trie.replace(
      foods,
      key(foodId),
      Nat32.equal,
      ?food,
    ).0;
    return foodId;
  };

  // Read a superhero.
  public query func read(foodId : FoodId) : async ?Food {
    let result = Trie.find(foods, key(foodId), Nat32.equal);
    return result;
  };

  // Update a superhero.
  public func update(foodId : FoodId, food : Food) : async Bool {
    let result = Trie.find(foods, key(foodId), Nat32.equal);
    let exists = Option.isSome(result);
    if (exists) {
      foods := Trie.replace(
        foods,
        key(foodId),
        Nat32.equal,
        ?food,
      ).0;
    };
    return exists;
  };

  // Delete a superhero.
  public func delete(foodId : FoodId) : async Bool {
    let result = Trie.find(foods, key(foodId), Nat32.equal);
    let exists = Option.isSome(result);
    if (exists) {
      foods := Trie.replace(
        foods,
        key(foodId),
        Nat32.equal,
        null,
      ).0;
    };
    return exists;
  };

  // cüzdana para ekler
  public func addMoney(amount : Nat32) : async Nat32 {
    wallet += amount;
    return wallet;
  };

  // order için gerekli olan fonksiyon eğer yeterli paran varsa sipariş verir ve parandan düşer
  public func Order(foodId : FoodId) : async Bool { 
    let foodOpt = Trie.find(foods, key(foodId), Nat32.equal);
    switch foodOpt {
      case null {
        return false; 
      };
      case (?food) {
        if (wallet >= food.price) {
          wallet -= food.price;
          return true; 
        } else {
          return false; 
        };
      };
    };
  };

  public query func Getwallet() : async Nat32 {
    return wallet; // bakiyeni gösterir
  };

  /**
   * Utilities
   */

  // Create a trie key from a superhero identifier.
  private func key(x : FoodId) : Trie.Key<FoodId> {
    return { hash = x; key=x};
  };
};
