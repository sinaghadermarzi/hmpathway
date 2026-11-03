# hmpathway

MATLAB scripts for coarsening a metabolic network by hypergraph partitioning and computing
elementary flux modes (EFMs) on the coarsened model, plus helpers to export networks for
visualization in yEd.

Models are handled as a "metatool" style struct `metamodel` with fields `st` (stoichiometric
matrix, metabolites × reactions), `irrev_react` (irreversibility flags per reaction) and `ext`
(external metabolites). It is built either from an SBML file (`TranslateSBML` +
`sbmlModel2metatool`) or from a COBRA model (`cobramodel.S`, `cobramodel.rev`).

## Main pipeline (`Partition.m`)

1. `KPartition.m` / `SPartition.m` — select intermediate metabolites by degree threshold, write the
   remaining network in hMETIS input format and call hMETIS to split the metabolites into `k` groups.
2. `Legalize.m` — makes the grouping consistent at reactions that span several groups (introduces
   dummy metabolites/reactions) and returns the new model, group and reaction-to-group mapping.
3. `Convert_Pathways_to_Reactions.m` — computes the EFMs of every sub-network and replaces each
   sub-network by its pathways, producing a coarse model (`coarse_model`), the expanded sub-EFMs and
   a mapping (`coarse_net_info`).
4. On request (`c`), `CalculateFluxModes` (efmtool) runs on the coarse model and the coarse EFMs are
   expanded back to fine-grained flux vectors. `Rank_Test.m` checks candidate flux vectors for the
   rank, steady-state and irreversibility conditions of an EFM.

`Partition_batch.m` is the same flow without the interactive prompt; `coarsen_reactions.m` is an
older script version of step 3 that works on `sub_groups` (a cell array of metabolite index groups)
instead of a group vector, and `coarsen_reactions.prj` is its MATLAB Coder (R2015b) project.

## Other scripts

- `Create_yed_csv_1_0_1.m`, `Create_yed_csv_grouped.m` (and the `_without_efms` variants) — write
  `nodelist.csv` / `edgelist.csv` bipartite metabolite–reaction graphs, optionally annotated with
  EFM membership, for import into yEd. `nodelist.csv` and `edgelist.csv` in the repo are an example
  output (a glycolysis model: 83 nodes, 118 edges).
- `calc_subnet_efms.m`, `calculate_efm_eqs.m`, `reaction_formulas.m` — EFMs per sub-network, net
  equations of EFMs in terms of external metabolites, and reaction formulas from a stoichiometric matrix.
- `elementarity.m`, `n_of_subnet_kernel_vectors.m`, `remove_zero_and_equivalent_efms.m`,
  `find_reverses.m` — checks on EFM sets (kernel dimension of the support, duplicates, reverse pairs).
- `Stoich2Connectivity.m`, `visit_node.m` — metabolite adjacency matrix and connected components.
- `reduce_model.m` — keeps a random subset of reactions (test model). `my_reduce.m` / `reduce.m`
  wrap the metatool reduction (`reduce.m` is Axel von Kamp's GPL code from metatool).
- `checkforconsistency.m` — COBRA `checkStoichiometricConsistency` on a model read with `readCbModel`.
- `conv_group.m`, `Untitled.m` — small scratch snippets. `ooo.txt` is a dumped 549 × 1082
  stoichiometric matrix.

## Requirements

- MATLAB (the Coder project targets R2015b).
- [efmtool](https://csb.ethz.ch/tools/software/efmtool.html) on the path for `CalculateFluxModes`.
- [hMETIS](http://glaros.dtc.umn.edu/gkhome/metis/hmetis/overview) 1.5.3 (`shmetis`).
- libSBML MATLAB bindings (`TranslateSBML`) and `sbmlModel2metatool`, or the COBRA Toolbox
  (`readCbModel`, `checkStoichiometricConsistency`) to load models. `sbmlModel2metatool` is not in
  this repo.

Paths to hMETIS and efmtool are hard-coded as Windows paths (`C:\Users\Sina\...`) in
`KPartition.m`, `SPartition.m`, `Partition.m`, `Partition_batch.m` and `reduce_model.m`; edit them
before running. Most files are scripts, not functions: they expect `metamodel` (and for some,
`sub_groups`, `res` or `fined_efms`) to already exist in the workspace.
