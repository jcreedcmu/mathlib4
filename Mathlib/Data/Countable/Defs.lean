/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov
-/
import Mathlib.Data.Finite.Defs
import Mathlib.Tactic.MkIffOfInductiveProp

/-!
# Countable types

In this file we define a typeclass saying that a given `Sort _` is countable. See also `Encodable`
for a version that singles out a specific encoding of elements of `α` by natural numbers.

This file also provides a few instances of this typeclass. More instances can be found in other
files.
-/


open Function

universe u v

variable {α : Sort u} {β : Sort v}

/-!
### Definition and basic properties
-/


/-- A type `α` is countable if there exists an injective map `α → ℕ`. -/
@[mk_iff countable_iff_exists_injective]
class Countable (α : Sort u) : Prop where
  /-- A type `α` is countable if there exists an injective map `α → ℕ`. -/
  exists_injective_nat' : ∃ f : α → ℕ, Injective f

lemma Countable.exists_injective_nat (α : Sort u) [Countable α] :
  ∃ f : α → ℕ, Injective f :=
Countable.exists_injective_nat'

instance : Countable ℕ :=
  ⟨⟨id, injective_id⟩⟩

export Countable (exists_injective_nat)

protected theorem Function.Injective.countable [Countable β] {f : α → β} (hf : Injective f) :
  Countable α :=
  let ⟨g, hg⟩ := exists_injective_nat β
  ⟨⟨g ∘ f, hg.comp hf⟩⟩

protected theorem Function.Surjective.countable [Countable α] {f : α → β} (hf : Surjective f) :
  Countable β :=
  (injective_surjInv hf).countable

theorem exists_surjective_nat (α : Sort u) [Nonempty α] [Countable α] : ∃ f : ℕ → α, Surjective f :=
  let ⟨f, hf⟩ := exists_injective_nat α
  ⟨invFun f, invFun_surjective hf⟩

theorem countable_iff_exists_surjective [Nonempty α] : Countable α ↔ ∃ f : ℕ → α, Surjective f :=
  ⟨@exists_surjective_nat _ _, fun ⟨_, hf⟩ ↦ hf.countable⟩

theorem Countable.of_equiv (α : Sort _) [Countable α] (e : α ≃ β) : Countable β :=
  e.symm.injective.countable

theorem Equiv.countable_iff (e : α ≃ β) : Countable α ↔ Countable β :=
  ⟨fun h => @Countable.of_equiv _ _ h e, fun h => @Countable.of_equiv _ _ h e.symm⟩

instance {β : Type v} [Countable β] : Countable (ULift.{u} β) :=
  Countable.of_equiv _ Equiv.ulift.symm

/-!
### Operations on `Sort _`s
-/


instance [Countable α] : Countable (PLift α) :=
  Equiv.plift.injective.countable

instance (priority := 100) Subsingleton.to_countable [Subsingleton α] : Countable α :=
  ⟨⟨fun _ => 0, fun x y _ => Subsingleton.elim x y⟩⟩

instance (priority := 500) [Countable α] {p : α → Prop} : Countable { x // p x } :=
  Subtype.val_injective.countable

instance {n : ℕ} : Countable (Fin n) :=
  Function.Injective.countable (@Fin.eq_of_veq n)

instance (priority := 100) Finite.to_countable [Finite α] : Countable α :=
  let ⟨_, ⟨e⟩⟩ := Finite.exists_equiv_fin α
  Countable.of_equiv _ e.symm

instance : Countable PUnit.{u} :=
  Subsingleton.to_countable

instance (priority := 100) Prop.countable (p : Prop) : Countable p :=
  Subsingleton.to_countable

instance Bool.countable : Countable Bool :=
  ⟨⟨fun b => cond b 0 1, Bool.injective_iff.2 Nat.one_ne_zero⟩⟩

instance Prop.countable' : Countable Prop :=
  Countable.of_equiv Bool Equiv.propEquivBool.symm

instance (priority := 500) [Countable α] {r : α → α → Prop} : Countable (Quot r) :=
  (surjective_quot_mk r).countable

instance (priority := 500) [Countable α] {s : Setoid α} : Countable (Quotient s) :=
  (inferInstance : Countable (@Quot α _))
