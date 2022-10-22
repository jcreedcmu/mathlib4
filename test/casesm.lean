import Mathlib.Tactic.CasesM
import Std.Tactic.GuardExpr

example (h : a ∧ b ∨ c ∧ d) (h2 : e ∧ f) : True := by
  casesm* _∨_, _∧_
  · clear ‹a› ‹b› ‹e› ‹f›; (fail_if_success clear ‹c›); trivial
  · clear ‹c› ‹d› ‹e› ‹f›; trivial

example (h : a ∧ b ∨ c ∧ d) : True := by
  casesm* _∧_
  clear ‹a ∧ b ∨ c ∧ d›; trivial

example (h : a ∧ b ∨ c ∨ d) : True := by
  casesm* _∨_
  · clear ‹a ∧ b›; trivial
  · clear ‹c›; trivial
  · clear ‹d›; trivial

example (h : a ∧ b ∨ c ∨ d) : True := by
  casesm _∨_
  · clear ‹a ∧ b›; trivial
  · clear ‹c ∨ d›; trivial

example (h : a ∧ b ∨ c ∨ d) : True := by
  cases_type And Or
  · clear ‹a ∧ b›; trivial
  · clear ‹c ∨ d›; trivial

example (h : a ∧ b ∨ c ∨ d) : True := by
  cases_type And
  · clear ‹a ∧ b ∨ c ∨ d›; trivial

example (h : a ∧ b ∨ c ∨ d) : True := by
  cases_type Or
  · clear ‹a ∧ b›; trivial
  · clear ‹c ∨ d›; trivial

example (h : a ∧ b ∨ c ∨ d) : True := by
  cases_type* Or
  · clear ‹a ∧ b›; trivial
  · clear ‹c›; trivial
  · clear ‹d›; trivial

example (h : a ∧ b ∨ c ∨ d) : True := by
  cases_type! And Or
  · clear ‹a ∧ b ∨ c ∨ d›; trivial

example (h : a ∧ b ∧ (c ∨ d)) : True := by
  cases_type! And Or
  · clear ‹a› ‹b ∧ (c ∨ d)›; trivial

example (h : a ∧ b ∧ (c ∨ d)) : True := by
  cases_type!* And Or
  · clear ‹a› ‹b› ‹c ∨ d›; trivial

inductive Test : Nat → Prop
  | foo : Test 0
  | bar : False → Test (n + 1)

example (_ : Test n) (h2 : Test (m + 1)) : True := by
  cases_type!* Test
  · clear ‹Test n› ‹False›; trivial

example (_ : Test n) (h2 : Test (m + 1)) : True := by
  cases_type Test
  · clear ‹Test (m + 1)›; trivial
  · clear ‹False› ‹Test (m + 1)›; trivial

example (_ : Test n) (h2 : Test (m + 1)) : True := by
  cases_type* Test
  · clear ‹False›; trivial
  · clear ‹False›; clear ‹False›; trivial

example : True ∧ True ∧ True := by
  constructorm True, _∨_
  guard_target = True ∧ True ∧ True
  constructorm _∧_
  · guard_target = True; constructorm True
  · guard_target = True ∧ True; constructorm* True, _∧_