/-
Copyright (c) 2021 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen
-/
import Mathlib.Logic.Function.Basic
import Mathlib.Tactic.NormCast

/-!
# Typeclass for a type `F` with an injective map to `A → B`

This typeclass is primarily for use by homomorphisms like `MonoidHom` and `LinearMap`.

## Basic usage of `FunLike`

A typical type of morphisms should be declared as:
```
structure MyHom (A B : Type*) [MyClass A] [MyClass B] :=
(toFun : A → B)
(map_op' : ∀ {x y : A}, toFun (MyClass.op x y) = MyClass.op (toFun x) (toFun y))

namespace MyHom

variables (A B : Type*) [MyClass A] [MyClass B]

-- This instance is optional if you follow the "morphism class" design below:
instance : FunLike (MyHom A B) A (λ _, B) :=
{ coe := MyHom.toFun, coe_injective' := λ f g h, by cases f; cases g; congr' }

/-- Helper instance for when there's too many metavariables to apply
`FunLike.coe` directly. -/
instance : CoeFun (MyHom A B) (λ _, A → B) := ⟨MyHom.toFun⟩

@[ext] theorem ext {f g : MyHom A B} (h : ∀ x, f x = g x) : f = g := FunLike.ext f g h

/-- Copy of a `MyHom` with a new `toFun` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (f : MyHom A B) (f' : A → B) (h : f' = ⇑f) : MyHom A B :=
{ toFun := f',
  map_op' := h.symm ▸ f.map_op' }

end MyHom
```

This file will then provide a `CoeFun` instance and various
extensionality and simp lemmas.

## Morphism classes extending `FunLike`

The `FunLike` design provides further benefits if you put in a bit more work.
The first step is to extend `FunLike` to create a class of those types satisfying
the axioms of your new type of morphisms.
Continuing the example above:

```
/-- `MyHomClass F A B` states that `F` is a type of `MyClass.op`-preserving morphisms.
You should extend this class when you extend `MyHom`. -/
class MyHomClass (F : Type*) (A B : outParam <| Type*) [MyClass A] [MyClass B]
  extends FunLike F A (λ _, B) :=
(map_op : ∀ (f : F) (x y : A), f (MyClass.op x y) = MyClass.op (f x) (f y))

@[simp] lemma map_op {F A B : Type*} [MyClass A] [MyClass B] [MyHomClass F A B]
  (f : F) (x y : A) : f (MyClass.op x y) = MyClass.op (f x) (f y) :=
MyHomClass.map_op

-- You can replace `MyHom.FunLike` with the below instance:
instance : MyHomClass (MyHom A B) A B :=
{ coe := MyHom.toFun,
  coe_injective' := λ f g h, by cases f; cases g; congr',
  map_op := MyHom.map_op' }

-- [Insert `CoeFun`, `ext` and `copy` here]
```

The second step is to add instances of your new `MyHomClass` for all types extending `MyHom`.
Typically, you can just declare a new class analogous to `MyHomClass`:

```
structure CoolerHom (A B : Type*) [CoolClass A] [CoolClass B]
  extends MyHom A B :=
(map_cool' : toFun CoolClass.cool = CoolClass.cool)

class CoolerHomClass (F : Type*) (A B : outParam <| Type*) [CoolClass A] [CoolClass B]
  extends MyHomClass F A B :=
(map_cool : ∀ (f : F), f CoolClass.cool = CoolClass.cool)

@[simp] lemma map_cool {F A B : Type*} [CoolClass A] [CoolClass B] [CoolerHomClass F A B]
  (f : F) : f CoolClass.cool = CoolClass.cool :=
MyHomClass.map_op

-- You can also replace `MyHom.FunLike` with the below instance:
instance : CoolerHomClass (CoolHom A B) A B :=
{ coe := CoolHom.toFun,
  coe_injective' := λ f g h, by cases f; cases g; congr',
  map_op := CoolHom.map_op',
  map_cool := CoolHom.map_cool' }

-- [Insert `CoeFun`, `ext` and `copy` here]
```

Then any declaration taking a specific type of morphisms as parameter can instead take the
class you just defined:
```
-- Compare with: lemma do_something (f : MyHom A B) : sorry := sorry
lemma do_something {F : Type*} [MyHomClass F A B] (f : F) : sorry := sorry
```

This means anything set up for `MyHom`s will automatically work for `CoolerHomClass`es,
and defining `CoolerHomClass` only takes a constant amount of effort,
instead of linearly increasing the work per `MyHom`-related declaration.

-/

-- This instance should have low priority, to ensure we follow the chain
-- `FunLike → CoeFun`
-- Porting note: this is an elaboration detail from Lean 3, we are going to disable it
-- until it is clearer what the Lean 4 elaborator needs.
-- attribute [instance, priority 10] coe_fn_trans

/-- The class `FunLike F α β` expresses that terms of type `F` have an
injective coercion to functions from `α` to `β`.

This typeclass is used in the definition of the homomorphism typeclasses,
such as `zero_hom_class`, `mul_hom_class`, `monoid_hom_class`, ....
-/
class FunLike (F : Sort _) (α : outParam (Sort _)) (β : outParam <| α → Sort _) where
  /-- The coercion from `F` to a function. -/
  coe : F → ∀ a : α, β a
  /-- The coercion to functions must be injective. -/
  coe_injective' : Function.Injective coe

section Dependent

/-! ### `FunLike F α β` where `β` depends on `a : α` -/

variable (F α : Sort _) (β : α → Sort _)

namespace FunLike

variable {F α β} [i : FunLike F α β]

-- Give this a priority between `coe_fn_trans` and the default priority
-- `α` and `β` are out_params, so this instance should not be dangerous
-- Porting note: @[nolint dangerous_instance]
instance (priority := 100) : CoeFun F fun _ => ∀ a : α, β a where coe := FunLike.coe

#eval Lean.Elab.Command.liftTermElabM do
  Tactic.NormCast.registerCoercion ``FunLike.coe
    (some { numArgs := 5, coercee := 4, type := .coeFun })

@[simp]
theorem coe_eq_coe_fn : (FunLike.coe : F → ∀ a : α, β a) = (fun f => ↑f) :=
  rfl

theorem coe_injective : Function.Injective (fun f : F => (f : ∀ a : α, β a)) :=
  FunLike.coe_injective'

@[simp]
theorem coe_fn_eq {f g : F} : (f : ∀ a : α, β a) = (g : ∀ a : α, β a) ↔ f = g :=
  ⟨fun h => FunLike.coe_injective' h, fun h => by cases h <;> rfl⟩

theorem ext' {f g : F} (h : (f : ∀ a : α, β a) = (g : ∀ a : α, β a)) : f = g :=
  FunLike.coe_injective' h

theorem ext'_iff {f g : F} : f = g ↔ (f : ∀ a : α, β a) = (g : ∀ a : α, β a) :=
  coe_fn_eq.symm

theorem ext (f g : F) (h : ∀ x : α, f x = g x) : f = g :=
  FunLike.coe_injective' (funext h)

theorem ext_iff {f g : F} : f = g ↔ ∀ x, f x = g x :=
  coe_fn_eq.symm.trans Function.funext_iff

protected theorem congr_fun {f g : F} (h₁ : f = g) (x : α) : f x = g x :=
  congr_fun (congr_arg _ h₁) x

theorem ne_iff {f g : F} : f ≠ g ↔ ∃ a, f a ≠ g a :=
  ext_iff.not.trans not_forall

theorem exists_ne {f g : F} (h : f ≠ g) : ∃ x, f x ≠ g x :=
  ne_iff.mp h

end FunLike

end Dependent

section NonDependent

/-! ### `FunLike F α (λ _, β)` where `β` does not depend on `a : α` -/

variable {F α β : Sort _} [i : FunLike F α fun _ => β]

namespace FunLike

protected theorem congr {f g : F} {x y : α} (h₁ : f = g) (h₂ : x = y) : f x = g y :=
  congr (congr_arg _ h₁) h₂

protected theorem congr_arg (f : F) {x y : α} (h₂ : x = y) : f x = f y :=
  congr_arg _ h₂

end FunLike

end NonDependent