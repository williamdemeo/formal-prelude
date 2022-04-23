------------------------------------------------------------------------
-- Enumerable types with an (infinite) stream witness.
------------------------------------------------------------------------

-- {-# OPTIONS --sized-types #-}
module Prelude.InfEnumerable where

open import Prelude.Init
open L.Mem
open import Prelude.Nary
open import Prelude.Lists
open import Prelude.Decidable
open import Prelude.DecEq
open import Prelude.ToN
open import Prelude.FromN
open import Prelude.Ord

-- Enumerable∞ A = A ↔ ℕ
record Enumerable∞ (A : Set ℓ) : Set ℓ where
  field enum : A Fun.↔ ℕ
open Enumerable∞ ⦃...⦄ public

private variable A : Set ℓ

instance
  Enumerable∞-ℕ : Enumerable∞ ℕ
  Enumerable∞-ℕ .enum = record
    { f = id ; f⁻¹ = id
    ; cong₁ = λ{ refl → refl } ; cong₂ = λ{ refl → refl }
    ; inverse = (λ _ → refl) , (λ _ → refl) }

  Enumerable∞⇒ToN : ⦃ Enumerable∞ A ⦄ → Toℕ A
  Enumerable∞⇒ToN .toℕ = enum .Fun.Inverse.f

  Enumerable∞⇒FromN : ⦃ Enumerable∞ A ⦄ → Fromℕ A
  Enumerable∞⇒FromN .fromℕ = enum .Fun.Inverse.f⁻¹

freshℕ : (xs : List ℕ) → ∃ (_∉ xs)
freshℕ xs = suc (∑ℕ xs) , λ x∈ → ¬suc≰ _ (x∈∑ℕ x∈)
  where
    ¬suc≰ : ∀ n → suc n ≰ n
    ¬suc≰ (suc n) (s≤s p) = ¬suc≰ n p

fromℕ∈⇒∈toℕ : ∀ ⦃ _ : Enumerable∞ A ⦄ n (xs : List A) → fromℕ n ∈ xs → n ∈ map toℕ xs
fromℕ∈⇒∈toℕ n xs x∈ =
  subst (_∈ map toℕ xs) (enum .Fun.Inverse.inverse .proj₁ n) $
  L.Mem.∈-map⁺ toℕ {x = fromℕ n} {xs = xs} x∈

fresh : ⦃ Enumerable∞ A ⦄ → (xs : List A) → ∃ (_∉ xs)
fresh xs =
  let n , n∉ = freshℕ (map toℕ xs)
  in  fromℕ n , n∉ ∘ fromℕ∈⇒∈toℕ _ _

-- record Enumerable∞ (A : Set ℓ) : Set ℓ where
--   field witness  : Stream A ∞
--         infinite : ∀ x → x ∈ˢ witness
-- open Enumerable∞ ⦃...⦄ public

-- instance
--   Enumerable∞-ℕ : Enumerable∞ ℕ
--   Enumerable∞-ℕ .witness = iterate suc 0