(* --------------------------------------------------------------------
 * (c) Copyright 2011--2012 Microsoft Corporation and Inria.
 * (c) Copyright 2012--2014 Inria.
 * (c) Copyright 2012--2014 IMDEA Software Institute.
 * -------------------------------------------------------------------- *)

(* -------------------------------------------------------------------- *)
From mathcomp Require Import ssreflect eqtype ssrbool ssrnat ssrfun seq.
From mathcomp Require Import choice ssralg bigop.

Import GRing.Theory.

Open Local Scope ring_scope.

Set Implicit Arguments.
Unset Strict Implicit.

Local Notation simpm := Monoid.simpm.

Require Import NArith ZArith BinPos Ring_polynom Field_theory.

(* -------------------------------------------------------------------- *)
Reserved Notation "x %:S" (at level 2, left associativity, format "x %:S").

Notation "c %:S"   := (PEc c)     : ssring.
Notation "''X_' i" := (PEX _ i)   : ssring.
Notation "x + y"   := (PEadd x y) : ssring.
Notation "x - y"   := (PEsub x y) : ssring.
Notation "- x"     := (PEopp x  ) : ssring.
Notation "x * y"   := (PEmul x y) : ssring.
Notation "x ^+ n"  := (PEpow x n) : ssring.

Notation "0" := PEO : ssring.
Notation "1" := PEI : ssring.

Delimit Scope ssring with S.

(* -------------------------------------------------------------------- *)
Notation "c %:S"   := (FEc c)     : ssfield.
Notation "''X_' i" := (FEX _ i)   : ssfield.
Notation "x + y"   := (FEadd x y) : ssfield.
Notation "x - y"   := (FEsub x y) : ssfield.
Notation "- x"     := (FEopp x  ) : ssfield.
Notation "x * y"   := (FEmul x y) : ssfield.
Notation "x ^-1"   := (FEinv x)   : ssfield.
Notation "x / y"   := (FEdiv x y) : ssfield.
Notation "x ^+ n"  := (FEpow x n) : ssfield.

Notation "0" := FEO : ssfield.
Notation "1" := FEI : ssfield.

Delimit Scope ssfield with F.

(* -------------------------------------------------------------------- *)
Local Coercion Z_of_nat      : nat >-> Z.
Local Coercion N_of_nat      : nat >-> N.
Local Coercion P_of_succ_nat : nat >-> positive.
Local Coercion Z.pos         : positive >-> Z.

(* -------------------------------------------------------------------- *)
Class find (T : Type) (x : T) (xs : seq T) (i:nat).

Instance find0 (T : Type) (x : T) (xs : seq T)
 : find x (x :: xs) 0.

Instance findS (T : Type) (x : T) (y : T) (ys :  seq T) i
 {_: find x ys i}
 : find x (y :: ys) i.+1 | 1.

(* -------------------------------------------------------------------- *)
Class closed (T : Type) (xs : seq T).

Instance closed_nil T
 : closed (T:=T) nil.

Instance closed_cons T (x : T) (xs : seq T)
 {_: closed xs}
 : closed (x :: xs).

(* -------------------------------------------------------------------- *)
Class reify (R : idomainType) (a : R) (t : PExpr Z) (e : seq R).

Instance reify_zero (R : idomainType) e : @reify R 0 0%S e.
Instance reify_one  (R : idomainType) e : @reify R 1 1%S e.

Instance reify_natconst (R : idomainType) n e
  : @reify R n%:R ((n : Z)%:S)%S e.

Instance reify_add (R : idomainType) a1 a2 t1 t2 e
  {_: @reify R a1 t1 e}
  {_: @reify R a2 t2 e}
  : reify (a1 + a2) (t1 + t2)%S e.

Instance reify_opp (R : idomainType) a t e
  {_: @reify R a t e}
  : reify (-a) (-t)%S e.

Instance reify_natmul (R : idomainType) a n t e
  {_: @reify R a t e}
  : reify (a *+ n) (t * (n : Z)%:S)%S e.

Instance reify_mul (R : idomainType) a1 a2 t1 t2 e
  {_: @reify R a1 t1 e}
  {_: @reify R a2 t2 e}
  : reify (a1 * a2) (t1 * t2)%S e.

Instance reify_exp (R : idomainType) a n t e
  {_: @reify R a t e}
  : reify (a ^+ n) (t ^+ n)%S e | 1.

Instance reify_var (R : idomainType) a i e
  `{find R a e i}
  : reify a ('X_i)%S e
  | 100.

Definition reifyl (R : idomainType) a t e
  {_: @reify R a t e}
  `{closed (T := R) e}
  := (t, e).

(* -------------------------------------------------------------------- *)
Ltac reify xt xe :=
  match goal with
  |- ?a = 0 =>
     match eval red in (reifyl (a := a)) with
     | (?t, ?e) => pose xt := t; pose xe := e
     end
  end.

(* -------------------------------------------------------------------- *)
Class freify (F : fieldType) (a : F) (t : FExpr Z) (e : seq F).

Instance freify_zero (F : fieldType) e : @freify F 0 0%F e.
Instance freify_one  (F : fieldType) e : @freify F 1 1%F e.

Instance freify_natconst (F : fieldType) n e
  : @freify F n%:R ((n : Z)%:S)%F e.

Instance freify_add (F : fieldType) a1 a2 t1 t2 e
  {_: @freify F a1 t1 e}
  {_: @freify F a2 t2 e}
  : freify (a1 + a2) (t1 + t2)%F e.

Instance freify_opp (F : fieldType) a t e
  {_: @freify F a t e}
  : freify (-a) (-t)%F e.

Instance freify_natmul (F : fieldType) a n t e
  {_: @freify F a t e}
  : freify (a *+ n) (t * (n : Z)%:S)%F e.

Instance freify_mul (F : fieldType) a1 a2 t1 t2 e
  {_: @freify F a1 t1 e}
  {_: @freify F a2 t2 e}
  : freify (a1 * a2) (t1 * t2)%F e.

Instance freify_inv (F : fieldType) a t e
  {_: @freify F a t e}
  : freify (a^-1) (t^-1)%F e.

Instance freify_exp (F : fieldType) a n t e
  {_: @freify F a t e}
  : freify (a ^+ n) (t ^+ n)%F e | 1.

Instance freify_var (F : fieldType) a i e
  `{find F a e i}
  : freify a ('X_i)%F e
  | 100.

Definition freifyl (F : fieldType) a t e
  {_: @freify F a t e}
  `{closed (T := F) e}
  := (t, e).

(* -------------------------------------------------------------------- *)
Ltac freify xt xe :=
  match goal with
  |- ?a = 0 =>
     match eval red in (freifyl (a := a)) with
     | (?t, ?e) => pose xt := t; pose xe := e
     end
  end.

(* -------------------------------------------------------------------- *)
Definition R_of_Z (R : ringType) (z : Z) : R :=
  match z with
  | Z0     => 0
  | Zpos n =>   (nat_of_P n)%:R
  | Zneg n => - (nat_of_P n)%:R
  end.

Implicit Arguments R_of_Z [R].

Lemma eqposP (x y : positive): reflect (x = y) (Peqb x y).
Proof. by apply: (iffP idP); move/Peqb_eq. Qed.

Definition pos_eqMixin := EqMixin eqposP.
Canonical pos_eqType := Eval hnf in (EqType positive pos_eqMixin).

Definition pos_pickle   (p : positive) := nat_of_P p.
Definition pos_unpickle (n : nat) := Ppred (P_of_succ_nat n).

Lemma pos_pickleK: cancel pos_pickle pos_unpickle.
Proof.
  move=> p; rewrite /pos_unpickle /pos_pickle.
  by rewrite pred_o_P_of_succ_nat_o_nat_of_P_eq_id.
Qed.

Definition pos_countMixin := CanCountMixin pos_pickleK.
Definition pos_choiceMixin := CountChoiceMixin pos_countMixin.

Canonical pos_choiceType := Eval hnf in (ChoiceType positive pos_choiceMixin).
Canonical pos_countType := Eval hnf in (CountType positive pos_countMixin).

Lemma eqZP (x y : Z): reflect (x = y) (Zeq_bool x y).
Proof. by apply: (iffP idP); move/Zeq_is_eq_bool. Qed.

Definition Z_eqMixin := EqMixin eqZP.
Canonical Z_eqType := Eval hnf in (EqType Z Z_eqMixin).

Definition Z_pickle z :=
  match z with
  | Z0     => inl _ tt
  | Zpos n => inr _ (inl _ (pos_pickle n))
  | Zneg n => inr _ (inr _ (pos_pickle n))
  end.

Definition Z_unpickle z :=
  match z with
  | inl tt      => Z0
  | inr (inl n) => Zpos (pos_unpickle n)
  | inr (inr n) => Zneg (pos_unpickle n)
  end.

Lemma Z_pickleK: cancel Z_pickle Z_unpickle.
Proof. by case=> [|n|n] //=; rewrite pos_pickleK. Qed.

Definition Z_countMixin := CanCountMixin Z_pickleK.
Definition Z_choiceMixin := CountChoiceMixin Z_countMixin.

Canonical Z_choiceType := Eval hnf in (ChoiceType Z Z_choiceMixin).
Canonical Z_countType := Eval hnf in (CountType Z Z_countMixin).

Definition Z_zmodMixin := ZmodMixin Zplus_assoc Zplus_comm Zplus_0_l Zplus_opp_l.
Canonical Z_zmodType := Eval hnf in (ZmodType Z Z_zmodMixin).

Definition Z_ringMixin :=
  RingMixin
    Zmult_assoc Zmult_1_l Zmult_1_r
    Zmult_plus_distr_l Zmult_plus_distr_r (erefl true).
Canonical Z_ringType := Eval hnf in (RingType Z Z_ringMixin).

Lemma z0E: 0%Z = 0.
Proof. by []. Qed.

Lemma zaddE (z1 z2 : Z): (z1 + z2)%Z = z1 + z2.
Proof. by []. Qed.

Lemma zoppE (z : Z): (-z)%Z = -z.
Proof. by []. Qed.

Lemma zmulE (z1 z2 : Z): (z1 * z2)%Z = z1 * z2.
Proof. by []. Qed.

Definition zE := (z0E, zaddE, zoppE).

Lemma R_of_Z_is_additive (R : ringType): additive (R_of_Z (R := R)).
Proof.
  have oppm: {morph (R_of_Z (R := R)) : x / -x >-> -x}.
    by case=> [|n|n] //=; rewrite ?(oppr0, opprK).
  have addm z1 z2: R_of_Z (z1 + z2) = R_of_Z z1 + R_of_Z z2 :> R.
    wlog: z1 z2 / (z1 <=? z2)%Z; first move=> wlog.
    + case: (boolP (z1 <=? z2))%Z; first by move/wlog.
    + move/negbTE/Z.leb_gt/Z.lt_le_incl/Z.leb_le.
      by move/wlog; rewrite Z.add_comm addrC.
    case: z1 z2=> [|n1|n1] [|n2|n2] //= _; rewrite ?(addr0, add0r) //.
    + by rewrite Pos2Nat.inj_add natrD.
    + case: (Z.compare_spec n1 n2) => [[->]||].
      * by rewrite Z.pos_sub_diag addrC subrr.
      * move=> lt; rewrite (Z.pos_sub_gt _ _ lt) /=.
        rewrite (Pos2Nat.inj_sub _ _ lt) natrB 1?addrC //.
        apply/leP/Pos2Nat.inj_le/Pos.lt_le_incl/Pos.ltb_lt.
        by rewrite Pos2Z.inj_ltb; apply/Pos.ltb_lt.
      * move=> lt; rewrite (Z.pos_sub_lt _ _ lt) /=.
        rewrite (Pos2Nat.inj_sub _ _ lt) natrB ?opprB 1?addrC //.
        apply/leP/Pos2Nat.inj_le/Pos.lt_le_incl/Pos.ltb_lt.
        by rewrite Pos2Z.inj_ltb; apply/Pos.ltb_lt.
    + by rewrite Pos2Nat.inj_add natrD opprD.
  by move=> z1 z2 /=; rewrite addm oppm.
Qed.

Canonical R_of_Z_additive (R : ringType) := Additive (R_of_Z_is_additive R).

Lemma R_of_Z_is_multiplicative (R : ringType): multiplicative (R_of_Z (R := R)).
Proof.
  split=> //=; case=> [|z1|z1] [|z2|z2] //=;
    rewrite ?simpm // ?(mulNr, mulrN, opprK);
    by rewrite nat_of_P_mult_morphism natrM.
Qed.

Canonical R_of_Z_rmorphism (R : ringType) := AddRMorphism (R_of_Z_is_multiplicative R).

Local Notation REeval :=
  (@PEeval _ 0 +%R *%R (fun x y => x - y) -%R Z R_of_Z nat nat_of_N (@GRing.exp _)).

Lemma RE (R : idomainType): @ring_eq_ext R +%R *%R -%R (@eq R).
Proof. by split; do! move=> ? _ <-. Qed.

Local Notation "~%R"   := (fun x y => x - y).
Local Notation "/%R"   := (fun x y => x / y).
Local Notation "^-1%R" := (@GRing.inv _) (only parsing).

Lemma RR (R : idomainType): @ring_theory R 0 1 +%R *%R ~%R -%R (@eq R).
Proof.
  split=> //=;
    [ exact: add0r | exact: addrC | exact: addrA  | exact: mul1r
    | exact: mulrC | exact: mulrA | exact: mulrDl | exact: subrr ].
Qed.

Lemma RZ (R : idomainType):
  ring_morph (R := R) 0 1 +%R *%R ~%R -%R eq
    0%Z 1%Z Zplus Zmult Zminus Zopp Zeq_bool (@R_of_Z _).
Proof.
  split=> //=.
  + by move=> x y; rewrite rmorphD.
  + by move=> x y; rewrite rmorphB.
  + by move=> x y; rewrite rmorphM.
  + by move=> x; rewrite raddfN.
  + by move=> x y /Zeq_bool_eq ->.
Qed.

Lemma PN (R : idomainType):
  @power_theory R 1 *%R eq nat nat_of_N (@GRing.exp R).
Proof.
  split=> r [|n] //=; elim: n => //= p ih.
  + by rewrite Pos2Nat.inj_xI exprS -!ih -exprD addnn -mul2n.
  + by rewrite Pos2Nat.inj_xO -!ih -exprD addnn -mul2n.
Qed.

Lemma RF (F : fieldType): @field_theory F 0 1 +%R *%R ~%R -%R /%R ^-1%R (@eq F).
Proof.
  split=> //=; first by apply RR.
  + by apply/eqP; rewrite oner_eq0.
  + by move=> x /eqP nz_z; rewrite mulVf.
Qed.

Definition Rcorrect (R : idomainType) :=
  ring_correct (Eqsth R) (RE R)
    (Rth_ARth (Eqsth R) (RE R) (RR R))
    (RZ R) (PN R)
    (triv_div_th
       (Eqsth R) (RE R)
       (Rth_ARth (Eqsth R) (RE R) (RR R)) (RZ R)).

Definition Fcorrect (F : fieldType) :=
  Field_correct
    (Eqsth F) (RE F) (congr1 GRing.inv)
    (F2AF (Eqsth F) (RE F) (RF F)) (RZ F) (PN F)
    (triv_div_th
       (Eqsth F) (RE F)
       (Rth_ARth (Eqsth F) (RE F) (RR F)) (RZ F)).

(* -------------------------------------------------------------------- *)
Fixpoint Reval (R : ringType) (l : seq R) (pe : PExpr Z) :=
  match pe with
  | 0%S           => 0
  | 1%S           => 1
  | (c%:S)%S      => R_of_Z c
  | ('X_j)%S      => BinList.nth 0 j l
  | (pe1 + pe2)%S => (Reval l pe1) + (Reval l pe2)
  | (pe1 - pe2)%S => (Reval l pe1) - (Reval l pe2)
  | (- pe1)%S     => - (Reval l pe1)
  | (pe1 ^+ n)%S  => (Reval l pe1) ^+ (nat_of_N n)
  | (pe1 * pe2)%S =>
      match pe2 with
      | ((Zpos n)%:S)%S => (Reval l pe1) *+ (nat_of_P n)
      | _               => (Reval l pe1) * (Reval l pe2)
      end
  end.

Local Notation RevalC R :=
  (PEeval 0 1 +%R *%R ~%R -%R (R_of_Z (R := R)) nat_of_N (@GRing.exp R)).

Lemma PEReval (R : ringType): RevalC _ =2 @Reval R.
Proof.
  move=> l; elim => //=; try by do? move=> ?->.
  + move=> pe1 -> pe2 ->; case: pe2 => //=.
    by case=> [|c|c] //=; rewrite mulr_natr.
Qed.

(* -------------------------------------------------------------------- *)
Fixpoint Feval (F : fieldType) (l : seq F) (pe : FExpr Z) :=
  match pe with
  | 0%F           => 0
  | 1%F           => 1
  | (c%:S)%F      => R_of_Z c
  | ('X_j)%F      => BinList.nth 0 j l
  | (pe1 + pe2)%F => (Feval l pe1) + (Feval l pe2)
  | (pe1 - pe2)%F => (Feval l pe1) - (Feval l pe2)
  | (- pe1)%F     => - (Feval l pe1)
  | (pe1 ^+ n)%F  => (Feval l pe1) ^+ (nat_of_N n)
  | (pe^-1)%F     => (Feval l pe)^-1
  | (pe1 / pe2)%F => (Feval l pe1) / (Feval l pe2)
  | (pe1 * pe2)%F =>
      match pe2 with
      | ((Zpos n)%:S)%F => (Feval l pe1) *+ (nat_of_P n)
      | _               => (Feval l pe1) * (Feval l pe2)
      end
  end.

Local Notation FevalC R :=
  (FEeval 0 1 +%R *%R ~%R -%R /%R ^-1%R
          (R_of_Z (R := R)) nat_of_N (@GRing.exp R)).

Lemma PEFeval (F : fieldType): FevalC _ =2 @Feval F.
Proof.
  move=> l; elim => //=; try by do? move=> ?->.
  + move=> pe1 -> pe2 ->; case: pe2 => //=.
    by case=> [|c|c] //=; rewrite mulr_natr.
Qed.

(* -------------------------------------------------------------------- *)
Ltac ssring :=
  let xt := fresh "xt" in
  let xe := fresh "xe" in
    apply/eqP; rewrite -subr_eq0; apply/eqP;
      rewrite ?(mulr0, mul0r, mulr1, mul1r); reify xt xe;
      move: (@Rcorrect _ 100 xe nil xt (Ring_polynom.PEc 0) I (erefl true));
      by rewrite !PEReval.

(* -------------------------------------------------------------------- *)
Ltac ssfield :=
  let xt := fresh "xt" in
  let xe := fresh "xe" in
    apply/eqP; rewrite -subr_eq0; apply/eqP;
      rewrite ?(mulr0, mul0r, mulr1, mul1r); freify xt xe;
      move: (@Fcorrect _ 100 xe nil xt (Field_theory.FEc 0) I nil (erefl nil));
      move/(_ _ (erefl _) _ (erefl _) (erefl true)); rewrite !PEFeval;
      apply=> /=; do? split; cbv delta[BinPos.Pos.to_nat] => /= {xt xe};
      try (exact I || apply/eqP).
