/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl
-/
import Mathlib.Algebra.Order.Monoid.Lemmas
import Mathlib.Order.BoundedOrder

/-!
# Ordered monoids

This file provides the definitions of ordered monoids.

-/


open Function

universe u

variable {α : Type u} {β : Type _}

/-- An ordered commutative monoid is a commutative monoid
with a partial order such that `a ≤ b → c * a ≤ c * b` (multiplication is monotone)
-/
class OrderedCommMonoid (α : Type _) extends CommMonoid α, PartialOrder α where
  /-- Multiplication is monotone in an `OrderedCommMonoid`. -/
  protected mul_le_mul_left : ∀ a b : α, a ≤ b → ∀ c : α, c * a ≤ c * b
#align ordered_comm_monoid OrderedCommMonoid

/-- An ordered (additive) commutative monoid is a commutative monoid
  with a partial order such that `a ≤ b → c + a ≤ c + b` (addition is monotone)
-/
class OrderedAddCommMonoid (α : Type _) extends AddCommMonoid α, PartialOrder α where
  /-- Addition is monotone in an `OrderedAddCommMonoid`. -/
  protected add_le_add_left : ∀ a b : α, a ≤ b → ∀ c : α, c + a ≤ c + b
#align ordered_add_comm_monoid OrderedAddCommMonoid

attribute [to_additive] OrderedCommMonoid

section OrderedInstances

@[to_additive]
instance OrderedCommMonoid.to_CovariantClass_left (M : Type _) [OrderedCommMonoid M] :
    CovariantClass M M (· * ·) (· ≤ ·) where
  elim := fun a _ _ bc ↦ OrderedCommMonoid.mul_le_mul_left _ _ bc a
#align ordered_comm_monoid.to_covariant_class_left OrderedCommMonoid.to_CovariantClass_left
#align ordered_add_comm_monoid.to_covariant_class_left OrderedAddCommMonoid.to_CovariantClass_left

/- This instance can be proven with `by apply_instance`.  However, `with_bot ℕ` does not
pick up a `CovariantClass M M (function.swap (*)) (≤)` instance without it (see PR mathlib#7940). -/
@[to_additive]
instance OrderedCommMonoid.to_CovariantClass_right (M : Type _) [OrderedCommMonoid M] :
    CovariantClass M M (swap (· * ·)) (· ≤ ·) :=
  covariant_swap_mul_le_of_covariant_mul_le M
#align ordered_comm_monoid.to_covariant_class_right OrderedCommMonoid.to_CovariantClass_right
#align ordered_add_comm_monoid.to_covariant_class_right OrderedAddCommMonoid.to_CovariantClass_right

/- This is not an instance, to avoid creating a loop in the type-class system: in a
`LeftCancelSemigroup` with a `PartialOrder`, assuming `CovariantClass M M (*) (≤)` implies
`CovariantClass M M (*) (<)`, see `LeftCancelSemigroup.covariant_mul_lt_of_covariant_mul_le`. -/
@[to_additive]
theorem Mul.to_CovariantClass_left (M : Type _) [Mul M] [PartialOrder M]
    [CovariantClass M M (· * ·) (· < ·)] :
    CovariantClass M M (· * ·) (· ≤ ·) :=
  ⟨covariant_le_of_covariant_lt _ _ _ CovariantClass.elim⟩
#align has_mul.to_covariant_class_left Mul.to_CovariantClass_left
#align has_add.to_covariant_class_left Add.to_CovariantClass_left

/- This is not an instance, to avoid creating a loop in the type-class system: in a
`RightCancelSemigroup` with a `PartialOrder`, assuming `CovariantClass M M (swap (*)) (<)`
implies `CovariantClass M M (swap (*)) (≤)`, see
`RightCancelSemigroup.covariant_swap_mul_lt_of_covariant_swap_mul_le`. -/
@[to_additive]
theorem Mul.to_CovariantClass_right (M : Type _) [Mul M] [PartialOrder M]
    [CovariantClass M M (swap (· * ·)) (· < ·)] :
    CovariantClass M M (swap (· * ·)) (· ≤ ·) :=
  ⟨covariant_le_of_covariant_lt _ _ _ CovariantClass.elim⟩
#align has_mul.to_covariant_class_right Mul.to_CovariantClass_right
#align has_add.to_covariant_class_right Add.to_CovariantClass_right

end OrderedInstances

set_option linter.deprecated false in
@[deprecated] theorem bit0_pos [OrderedAddCommMonoid α] {a : α} (h : 0 < a) : 0 < bit0 a :=
  add_pos' h h
#align bit0_pos bit0_pos

/-- A linearly ordered additive commutative monoid. -/
class LinearOrderedAddCommMonoid (α : Type _) extends LinearOrder α, OrderedAddCommMonoid α
#align linear_ordered_add_comm_monoid LinearOrderedAddCommMonoid

/-- A linearly ordered commutative monoid. -/
@[to_additive]
class LinearOrderedCommMonoid (α : Type _) extends LinearOrder α, OrderedCommMonoid α
#align linear_ordered_comm_monoid LinearOrderedCommMonoid

/-- A linearly ordered commutative monoid with an additively absorbing `⊤` element.
  Instances should include number systems with an infinite element adjoined.` -/
class LinearOrderedAddCommMonoidWithTop (α : Type _) extends LinearOrderedAddCommMonoid α,
    Top α where
  /-- In a `LinearOrderedAddCommMonoidWithTop`, the `⊤` element is larger than any other element.-/
  protected le_top : ∀ x : α, x ≤ ⊤
  /-- In a `LinearOrderedAddCommMonoidWithTop`, the `⊤` element is invariant under addition. -/
  protected top_add' : ∀ x : α, ⊤ + x = ⊤
#align linear_ordered_add_comm_monoid_with_top LinearOrderedAddCommMonoidWithTop

-- see Note [lower instance priority]
instance (priority := 100) LinearOrderedAddCommMonoidWithTop.toOrderTop (α : Type u)
    [h : LinearOrderedAddCommMonoidWithTop α] : OrderTop α :=
  { h with }
#align linear_ordered_add_comm_monoid_with_top.to_order_top
  LinearOrderedAddCommMonoidWithTop.toOrderTop

section LinearOrderedAddCommMonoidWithTop

variable [LinearOrderedAddCommMonoidWithTop α] {a b : α}

@[simp]
theorem top_add (a : α) : ⊤ + a = ⊤ :=
  LinearOrderedAddCommMonoidWithTop.top_add' a
#align top_add top_add

@[simp]
theorem add_top (a : α) : a + ⊤ = ⊤ :=
  Trans.trans (add_comm _ _) (top_add _)
#align add_top add_top

end LinearOrderedAddCommMonoidWithTop
