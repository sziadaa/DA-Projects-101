1- Create SQL Union for all related tables FIFA20-FIFA22 / Female_PLAYER20-22.
2- Place the above SQL in VIEW and make sure you add new columns called gender (male/female) to distinguish between them.
=

CREATE VIEW Fife20_21_22 AS 

SELECT *, 'Female' AS gender, 2020 as Year_ FROM [dbo].[female_players_20]
UNION ALL
SELECT *, 'Female' AS gender, 2021 as Year_  FROM [dbo].[female_players_21]
UNION ALL
SELECT *, 'Female' AS gender, 2022 as Year_   FROM [dbo].[female_players_22]
UNION ALL
SELECT *, 'Male' AS gender, 2020 as Year_   FROM [dbo].[players_20]
UNION ALL
SELECT *, 'Male' AS gender, 2021 as Year_  FROM [dbo].[players_21]
UNION ALL
SELECT *, 'Male' AS gender, 2022 as Year_  FROM [dbo].[players_22]

===================================================================================================
3- Write SQL to get Average age per gender and YEAR.

select AVG (age) as Avg_Age,gender,Year_

from [dbo].[Fife20_21_22] 

group by gender,Year_

===================================================================================================
4- Create Stored Procedure which retrive Top N Players the SP will take (N >> to get top number , Gender , Year)

CREATE PROCEDURE Top_N_Players 
	@n int,
	@Gender varchar(20),
	@Year_ int
AS
BEGIN
	select top  (@n) *

	from [dbo].[Fife20_21_22]

	where gender = @Gender   AND Year_ = @Year_

	order by overall desc
END

EXEC Top_N_Players @n = 2 , @Gender = 'Male' , @Year_ = 2020
EXEC Top_N_Players @n = 2 , @Gender = 'female' , @Year_ = 2020


