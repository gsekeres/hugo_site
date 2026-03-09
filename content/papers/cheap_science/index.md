---
title: "Editorial Screening when Science is Cheap"
date: 2026-03-09
lastmod: 2026-03-09
tags: ["editorial screening", "robustness checks", "specification search", "science of science", "false discovery rate"]
author: ["Nic Fishman","Gabriel Sekeres"]
description: "We theorize a model of editorial screening under a cost shift, and test it using a novel agentic specification search workflow."
summary: "We theorize a model of editorial screening under a cost shift, and test it using a novel agentic specification search workflow."
status: "Working Paper"
editPost:
    URL: "/papers/cheap_science/gsekeres_cheap_science.pdf"
    Text: "Working"

---

##### Download

+ [Paper](/papers/cheap_science/gsekeres_cheap_science.pdf)
+ [GitHub Repo](https://github.com/gsekeres/agentic-specification-search)


---

##### Abstract

We build a constrained, auditable agentic workflow that constructs an ex ante specification surface for each paper and then executes the robustness universe it admits, and we apply it to 103 empirical studies published in AEA journals. Comparing our automated runtime to a conservative human benchmark, we estimate a roughly 170-fold decline in the marginal cost of running observational specifications. We study the resulting shift in behavior as a commitment equilibrium of a screening game, where journals commit *ex ante* to acceptance rules and researchers sequentially search over dependent specifications, stop strategically, and selectively disclose evidence. The induced true- and false-positive acceptance rates trace out a purity--throughput frontier. We prove a universal information-theoretic bound on this frontier, governed by the total likelihood-ratio information a researcher can accumulate before optimally stopping. We verify that the current *de facto* practice in observational research, requiring a set of robustness checks, is an optimal mechanism; but we prove that screening collapses as testing becomes cheap unless the required number of robustness checks scales at least linearly in the inverse cost of each test. We then document, using audited ex ante specification surfaces and the robustness universes they induce, that observational social science has indeed entered a cheap-testing regime. The theory implies that to maintain conventional purity at fixed throughput, the number of qualifying robustness checks must grow at least proportionally with the cost decline; under our empirical calibration the implied disclosure requirement is on the order of 7,000 checks. This raises a serious issue for observational work going forward, and we argue for the need to develop methods to interpret sets of many specifications simultaneously, as opposed to current interpretative practice, which focuses on a handful of main specifications and a small set of robustness checks.

---
##### Figure 1: The Editorial Screening Frontier

![](figure1.png)

##### Figure 2: Validation of Agentic Specification Search

![](figure2.png)

##### Figure 4: Counterfactual Robustness Requirements

![](figure4.png)

---

##### Citation

Fishman, Nic and Gabriel Sekeres. 2026. "Editorial Screening when Science is Cheap." *Working Paper*.

```BibTeX
@article{fishmanSekeres2026,
author = {Nic Fishman and Gabriel Sekeres},
year = {2026},
title ={Editorial Screening when Science is Cheap},
journal = {Working Paper},
}
```

---