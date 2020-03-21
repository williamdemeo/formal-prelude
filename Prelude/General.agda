------------------------------------------------------------------------
-- General utilities
------------------------------------------------------------------------

module Prelude.General where

open import Data.Unit    using (tt)
open import Data.Product using (_×_; _,_; ∃-syntax)
open import Data.Bool    using (T; true; false; _∧_)
open import Data.Nat     using (_+_)
open import Data.Maybe   using (Maybe; nothing)
  renaming (just to pure; ap to _<*>_) -- for idiom brackets
open import Data.List    using (List; []; _∷_; foldr)

open import Data.Nat.Properties using (+-assoc; +-comm)

open import Data.List.Membership.Propositional using (_∈_; mapWith∈)
open import Data.List.Relation.Unary.Any       using (here; there)

open import Relation.Nullary                      using (¬_)
open import Relation.Binary.PropositionalEquality using (_≡_; _≢_; refl; sym)

private
  variable
    A B : Set
    x : A
    xs : List A

------------------------------------------------------------------------
-- Bools.

true⇒T : ∀ {b} → b ≡ true → T b
true⇒T refl = tt

T⇒true : ∀ {b} → T b → b ≡ true
T⇒true {true}  tt = refl
T⇒true {false} ()

⊥-bool : ∀ {b} → ¬ ((b ≡ true) × (b ≡ false))
⊥-bool (refl , ())

T-∧ : ∀ {l r} → T (l ∧ r) → T l × T r
T-∧ {true} {true} _ = tt , tt

∧-falseˡ : ∀ {r} → ¬ (T (false ∧ r))
∧-falseˡ {r = true}  ()
∧-falseˡ {r = false} ()

∧-falseʳ : ∀ {l} → ¬ (T (l ∧ false))
∧-falseʳ {l = true}  ()
∧-falseʳ {l = false} ()

∧-falseʳ² : ∀ {x y} → ¬ (T (x ∧ (y ∧ false)))
∧-falseʳ² {x = true}  {y = true}  ()
∧-falseʳ² {x = true}  {y = false} ()
∧-falseʳ² {x = false} {y = true}  ()
∧-falseʳ² {x = false} {y = false} ()

------------------------------------------------------------------------
-- Nats.

x+y+0≡y+x+0 : ∀ x y → x + (y + 0) ≡ (y + x) + 0
x+y+0≡y+x+0 x y rewrite sym (+-assoc x y 0) | +-comm x y = refl

------------------------------------------------------------------------
-- Maybes.

toMaybe : List A → Maybe A
toMaybe []      = nothing
toMaybe (x ∷ _) = pure x

toMaybe-≡ : ∀ {A : Set} {x : A} {xs : List A}
  → toMaybe xs ≡ pure x
  → ∃[ ys ] (xs ≡ x ∷ ys)
toMaybe-≡ {xs = _ ∷ _} refl = _ , refl

ap-nothing : ∀ {A B : Set} {r : B} {m : Maybe (A → B)} → (m <*> nothing) ≢ pure r
ap-nothing {m = nothing} ()
ap-nothing {m = pure _ } ()

------------------------------------------------------------------------
-- Lists.

sequence : ∀ {A : Set} → List (Maybe A) → Maybe (List A)
sequence = foldr (λ c cs → ⦇ c ∷ cs ⦈) (pure [])

singleton→∈ : ∃[ ys ] (xs ≡ x ∷ ys)
            → x ∈ xs
singleton→∈ (_ , refl) = here refl

mapWith∈⁺ : ∀ {x xs} {f : ∀ {x : A} → x ∈ xs → B}
  → (x∈ : x ∈ xs)
  → ∃[ y ] ( (y ∈ mapWith∈ xs f) × (f {x} x∈ ≡ y) )
mapWith∈⁺ {x = x} {xs = []}      ()
mapWith∈⁺ {x = x} {xs = .x ∷ xs} (here refl) = (_ , here refl , refl)
mapWith∈⁺ {x = x} {xs = x′ ∷ xs} (there x∈) with mapWith∈⁺ x∈
... | y , y∈ , refl = y , there y∈ , refl
