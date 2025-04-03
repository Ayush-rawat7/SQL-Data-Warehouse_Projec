/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

create or alter procedure silver.load_silver as
begin
    declare @start_time datetime, @end_time datetime, @batch_start_time datetime , @batch_end_time datetime;
	begin try

			set @batch_start_time = GETDATE();
			print '================================================';
			print 'Loading Silver Layer';
			print '================================================';

			print '================================================';
			print 'Loading CRM Tables';
			print '================================================';


			--(1)
			--loading silver.crm_cust_info
			set @start_time = GETDATE();
			print '>> Truncating Table : silver.crm_cust_info';
			truncate table silver.crm_cust_info;
			print '>> Inserting Data Into : silver.crm_cust_info';

			insert into silver.crm_cust_info (
				cst_id,
				cst_key,
				cst_firstname,
				cst_lastname,
				cst_material_status,
				cst_gndr,
				cst_create_date -- Corrected column name
			)

			select
			cst_id,
			cst_key,
			trim(cst_firstname) as cst_firstname,
			trim(cst_lastname) as cst_lastname,

			case when UPPER(trim(cst_material_status)) = 'S' then 'Single'
				 when UPPER(trim(cst_material_status)) = 'M' then 'Married'
				 else 'n/a'
			end cst_material_status,


			case when UPPER(trim(cst_gndr)) = 'F' then 'Female'
				 when UPPER(trim(cst_gndr)) = 'M' then 'Male'
				 else 'n/a'
			end cst_gndr,

			cst_create_date

			from (
			select
			*,
			ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last

			from bronze.crm_cust_info

			)t where flag_last = 1;

			set @end_time = GETDATE();
			print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
			print '>>---------------------';





			--(2)
			--loading silver.crm_cust_info
			set @start_time = GETDATE();
			print '>> Truncating Table : silver.crm_cust_info';
			truncate table silver.crm_cust_info;
			print '>> Inserting Data Into : silver.crm_cust_info';
	
			INSERT INTO silver.crm_prd_info (
				prd_id, 
				cat_id, 
				prd_key, 
				prd_nm, 
				prd_cost, 
				prd_line, 
				prd_start_dt, 
				prd_end_dt
			) 

			select
			prd_id,
			replace(SUBSTRING(prd_key, 1,5),'-','_') as cat_id,   -- we first create  a new column with substring from prd_key and then change the - in prd_key to _ of erp_px_cust_g1v2
			SUBSTRING(prd_key, 7,len(prd_key)) as prd_key,        -- created new column with the substring od prd_key
			prd_nm,
			isnull(prd_cost,0) as prd_cost,                       -- null values are converted to 0
	
			case when UPPER(trim(prd_line)) = 'M' then 'Mountain'   -- Data Normalization and Standardization
				 when UPPER(trim(prd_line)) = 'R' then 'Road'
				 when UPPER(trim(prd_line)) = 'S' then 'Other Sales'
				 when UPPER(trim(prd_line)) = 'T' then 'Touring'
				 else 'n/a'
			end as prd_line,

			cast( prd_start_dt as date) as prd_start_dt,             --datatype casting
			cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date)as  prd_end_dt  --datatype casting with data enrichment
			from bronze.crm_prd_info;
			set @end_time = GETDATE();
			print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
			print '>>---------------------';



			--(3)
			--loading silver.crm_sales_details
			set @start_time = GETDATE();
			print '>> Truncating Table : silver.crm_sales_details';
			truncate table silver.crm_sales_details;
			print '>> Inserting Data Into : silver.crm_sales_details';
	
			insert into silver.crm_sales_details(

				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_order_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_sales,
				sls_quantity,
				sls_price
			)

			SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case when sls_order_dt =0 or len(sls_order_dt) !=8 then null
				 else cast(cast(sls_order_dt as varchar) as date)
			end as sls_order_dt,

			case when sls_ship_dt =0 or len(sls_ship_dt) !=8 then null
				 else cast(cast(sls_ship_dt as varchar) as date)
			end as sls_ship_dt,

			case when sls_due_dt =0 or len(sls_due_dt) !=8 then null
				 else cast(cast(sls_due_dt as varchar) as date)
			end as sls_due_dt,

			case when sls_sales <= 0 or sls_sales is null or sls_sales != sls_quantity * abs(sls_price)
					  then  sls_quantity * abs(sls_price)
					else sls_sales
			end as sls_sales,

			sls_quantity,

			case when sls_price is null or sls_price <=0 
					  then sls_sales / nullif(sls_quantity,0)
					else sls_price
			end as sls_price

			FROM bronze.crm_sales_details;
			set @end_time = GETDATE();
			print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
			print '>>---------------------';



			--(4)
			--loading silver.erp_cust_az12 
			set @start_time = GETDATE();

			print '>> Truncating Table : silver.erp_cust_az12';
			truncate table silver.erp_cust_az12;
			print '>> Inserting Data Into : silver.erp_cust_az12';
			insert into silver.erp_cust_az12 (
			cid,
			bdate,
			gen
			)

			SELECT 

			case when cid like 'NAS%' then substring(cid,4,len(cid))     --remove 'NAS' prefix if present
				else cid
			end as cid,

			case when bdate > GETDATE() then null                  -- set future bithdates to null
				else bdate
			end as bdate,

			case when upper(trim(gen)) in ('F','Female') then 'female'   --data normalization
				 when upper(trim(gen)) in ('M', 'Male') then 'Male'
				 else 'n/a'
			end as gen

			FROM bronze.erp_cust_az12;
			set @end_time = GETDATE();
			print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
			print '>>---------------------';




			--(5)
			--loading silver.erp_loc_a101
			set @start_time = GETDATE();
			print '>> Truncating Table : silver.erp_loc_a101';
			truncate table silver.erp_loc_a101;
			print '>> Inserting Data Into : silver.erp_loc_a101';
	
			insert into silver.erp_loc_a101 (
			cid,
			cntry
			)

			SELECT  
			replace(cid,'-','') cid,  -- remove - from cid 

			case when trim(cntry) = 'DE' then 'Germany'
				 when trim(cntry) in ('US','USA') then 'United States'
				 when trim(cntry) = '' or cntry is null then 'n/a'
				 else trim(cntry)
			end as cntry

			FROM  bronze.erp_loc_a101;
			set @end_time = GETDATE();
			print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
			print '>>---------------------';



			--(6)
			--loading silver.erp_px_cat_g1v2
			set @start_time = GETDATE();
	
			print '>> Truncating Table : silver.erp_px_cat_g1v2';
			truncate table silver.erp_px_cat_g1v2;
			print '>> Inserting Data Into : silver.erp_px_cat_g1v2';
			insert into silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
			)

			SELECT 
			id,
			cat,
			subcat,
			maintenance

			FROM bronze.erp_px_cat_g1v2;
			set @end_time = GETDATE();
			print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
			print '>>---------------------';

			set @batch_end_time = GETDATE();
			print '>>=================================='
			print 'Loading silver layer is completed';
			print '>>  -Total Load Duration: ' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + 'seconds';
			print '>>---------------------';

	end try
	begin catch
			print '=========================================';
			print 'ERROR OCCURED DURING LOADING BRONZE LAYER';
			print 'Error Message' + ERROR_MESSAGE();
			print 'Error Message' + cast( ERROR_NUMBER() as nvarchar);
			print 'Error Message' + cast( ERROR_NUMBER() as nvarchar);
			print '=========================================';
	end catch
end

