graph TD
A[SRX<br/>M.ADP.Pi] --> |k_1| B[DRX<br/>M.ADP.Pi]
B --> |k_2| A
B --> |k_3,<br/>Attachment| C[Weakly-bound,<br/>A.M.ADP.Pi]
C --> |k_4,<br/>Detachment| B
C --> |k_5,<br/>Power stroke| D[Force generating<br/>A.M.ADP]
D --> |k_6| C
D --> |k_7,<br/>Second power<br/>stroke| E[Rigor state<br/>A.M]
E --> |k_8| D
E --> |k_9,<br/>ATP binding +<br/>detachment| F[M.ATP]
F --> |k_10| E
F --> |k_11,<br/>ATP hydrolysis| B
B --> |k_12| F
D --> |k_13,<br/>Forcible detachment| G[M.ADP]
G --> |k_14,<br/>Rapid attachment| D
G --> |k_15,<br/> ADP release,<br/> ATP binding and hydrolysis| B
B --> |k_16, <br/>Forbidden| G

