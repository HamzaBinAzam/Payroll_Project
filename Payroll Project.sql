--To See the whole Data
Select * From Accounts..Salary_Data

--To Add a Column for Mobile Allowance
Alter Table Accounts..Salary_Data
ADD Basic_Salary INT;

--To Calculate Basic Salary
UPDATE Accounts..Salary_Data
SET Basic_Salary = ([Gross Salary]-5000) * 0.666666;

--To Add New Columns For Mobile Allowance, House Rent , Travel Allowance and Medical Allowance
Alter Table Accounts..Salary_Data
ADD Mobile_Allowance INT
Alter Table Accounts..Salary_Data
ADD House_Rent INT
Alter Table Accounts..Salary_Data
ADD Medical_Allowance INT
Alter Table Accounts..Salary_Data
ADD Travel_Allowance INT;

--ADD Values in the above created Tables
UPDATE Accounts..Salary_Data
SET Mobile_Allowance = 5000;

UPDATE Accounts..Salary_Data
SET House_Rent = Basic_Salary * 0.3;


UPDATE Accounts..Salary_Data
SET Medical_Allowance = Basic_Salary * 0.1;


UPDATE Accounts..Salary_Data
SET Travel_Allowance = Basic_Salary * 0.1;

--To Add New Columns For Arreras in case of any Adjustments
Alter Table Accounts..Salary_Data
ADD Arrera INT;

UPDATE Accounts..Salary_Data                --To add Arreras for any employee enter the amount and the ID for that Employee.
SET Arrera = 
Where [Employee ID] = ;

--To remove the time stamp from Joinning and Existing Date

Alter Table Accounts..Salary_Data   --First We need to add two new columns for joinning and exit dates
ADD Joining_Date Date;

Alter Table Accounts..Salary_Data
ADD Exit_Date Date;

Update Accounts..Salary_Data
Set Joining_Date= DATEADD(dd,0,Datediff(dd,0,[Joining Date]))

Update Accounts..Salary_Data
SET Exit_Date = CONVERT(DATE, [Exit Date])


-----------------------------------------------------------------------PF Calculations---------------------------------------------------------
--Let's see on which date PF will be Applicable for each Employee

Alter Table Accounts..Salary_Data
ADD PF_Applicable_Date Date;

UPDATE Accounts..Salary_Data
SET PF_Applicable_Date = DATEADD(month,3,Joining_Date)

Alter Table Accounts..Salary_Data
ADD Today_Date Date;

UPDATE Accounts..Salary_Data
SET Today_Date = GETDATE()


Alter Table Accounts..Salary_Data
ADD Provident_Fund INT;

UPDATE Accounts..Salary_Data
SET Provident_Fund = CASE When Today_Date > PF_Applicable_Date
                          Then Basic_Salary * 0.085
						  Else 0 END 


-------------------------------------------------------------INCOME TAX--------------------------------------------------------------------

Alter Table Accounts..Salary_Data
ADD Income_Tax INT;

UPDATE Accounts..Salary_Data
SET Income_Tax = CASE
                 WHEN [Gross Salary] > 0 AND [Gross Salary] <= 50000
				 THEN (0+([Gross Salary]-0)*0)
				 WHEN [Gross Salary] > 50000 AND [Gross Salary] <= 100000
				 THEN (0+([Gross Salary]-50000)*0.025)
				 WHEN [Gross Salary] > 100000 AND [Gross Salary] <= 200000
				 THEN (1250+([Gross Salary]-100000)*0.125)
				 WHEN [Gross Salary] > 200000 AND [Gross Salary] <= 300000
				 THEN (13750+([Gross Salary]-200000)*0.2)
				 WHEN [Gross Salary] > 300000 AND [Gross Salary] <= 500000
				 THEN (33750+([Gross Salary]-300000)*0.25)
				 WHEN [Gross Salary] > 500000 AND [Gross Salary] <= 1000000
				 THEN (83750+([Gross Salary]-500000)*0.325)
				  WHEN [Gross Salary] > 1000000
				 THEN (246250+([Gross Salary]-1000000)*0.35)
				 ELSE 0 END
--To ADD some other deductions

ALTER TABLE Accounts..Salary_Data
ADD Other_Deductions INT;

UPDATE Accounts..Salary_Data                --To add other deductions for any employee enter the amount and the ID for that Employee.
SET Other_Deductions = 
Where [Employee ID] = ;

----------------------------------------------------NET SALARY---------------------------------------------------------

ALTER TABLE Accounts..Salary_Data
ADD Net_Salary INT;


UPDATE Accounts..Salary_Data
SET Net_Salary = (Basic_Salary+Mobile_Allowance+House_Rent+Medical_Allowance+Travel_Allowance-Provident_Fund-Income_Tax-
				  Case When Other_Deductions is NuLL 
				  Then 0
				  Else Other_Deductions END +
				  CASE WHEN Arrera is NuLL 
				  Then 0
				  Else Arrera END)

--To Get the Sheet for Payroll
SELECT S.[Employee ID]
      ,S.[Employee Name]
      ,S.[Designation]
	  ,E.[Department]
      ,S.[Confirmation Status]
      ,S.[Employement type]
      ,S.[Gross Salary]
      ,S.[Basic_Salary] as [Basic Salary]
	  
     -- ,[Mobile_Allowance]
     -- ,[House_Rent]
     -- ,[Medical_Allowance]
     -- ,[Travel_Allowance]
     -- ,[Arrera]
     -- ,[Joining_Date]
     -- ,[Exit_Date]
     -- ,[PF_Applicable_Date]
     -- ,[Today_Date]
     -- ,[Provident_Fund]
      ,[Income_Tax] as [Income Tax]
     -- ,[Other_Deductions]
      ,[Net_Salary] as [Net Salary]
  FROM [Accounts].[dbo].[Salary_Data] as S
  Join Accounts..Employees_Data as E
  ON S.[Employee ID]=E.[Employee ID]
  Where S.[Confirmation Status] <> 'Ex- Employee'


  --Total Payroll By each Department
  Select 
  E.Department, SUM(S.Net_Salary) as [Total Salary]
  From Accounts..Salary_Data as S
  Join Accounts..Employees_Data as E
  ON S.[Employee ID]=E.[Employee ID]
  Where S.[confirmation Status] <> 'Ex- Employee'
  Group By E.Department;

   --Total Tax Deductions By each Department
  Select 
  E.Department, SUM(S.Income_tax) as [Total Tax Deductions]
  From Accounts..Salary_Data as S
  Join Accounts..Employees_Data as E
  ON S.[Employee ID]=E.[Employee ID]
  Where S.[confirmation Status] <> 'Ex- Employee'
  Group By E.Department;