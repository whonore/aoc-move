From Coq Require Import Arith Lia List Permutation.

Definition product xs := fold_right Nat.mul 1 xs.

Lemma product_cons x xs : product (x :: xs) = x * product xs.
Proof. easy. Qed.

Lemma product_pos xs : Forall (fun n => n <> 0) xs -> product xs <> 0.
Proof.
  induction xs.
  - easy.
  - rewrite product_cons, Forall_cons_iff; intros (? & ?%IHxs).
    lia.
Qed.

Lemma product_perm xs ys : Permutation xs ys -> product xs = product ys.
Proof.
  induction 1.
  - easy.
  - now rewrite !product_cons; congruence.
  - now rewrite !product_cons, !Nat.mul_assoc, (Nat.mul_comm x y).
  - congruence.
Qed.

Lemma mod_mul x n m :
  n <> 0 ->
  m <> 0 ->
  (x mod (n * m)) mod n = x mod n.
Proof.
  intros.
  rewrite Nat.mod_mul_r by easy.
  rewrite Nat.mul_comm.
  rewrite Nat.mod_add by easy.
  now rewrite Nat.mod_mod by easy.
Qed.

Lemma mod_prod x ns :
  Forall (fun n => n <> 0) ns ->
  Forall (fun n => (x mod (product ns)) mod n = x mod n) ns.
Proof.
  revert x; induction ns as [| n ns]; intros x.
  - easy.
  - rewrite product_cons, !Forall_cons_iff; intros (? & Hpos).
    split.
    + now apply mod_mul; auto using product_pos.
    + rewrite Forall_forall; intros m Hm.
      pose proof Hm as (ns' & Hperm%Permutation_Add)%Add_inv.
      rewrite <- (product_perm (m :: ns')) by easy.
      rewrite product_cons, Nat.mul_assoc, (Nat.mul_comm n m), <- Nat.mul_assoc.
      enough (m <> 0 /\ product ns' <> 0) by now rewrite mod_mul by lia.
      rewrite <- Hperm in Hpos.
      apply Forall_cons_iff in Hpos as (? & ?).
      now split; [| apply product_pos].
Qed.
