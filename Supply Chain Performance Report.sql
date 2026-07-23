create table deliveries (
	delivery_id varchar(50),
	po_number varchar(50),
	mode_id varchar(50),
	actual_delivery_date date,
	quantity_received int,
	actual_shipping_cost numeric(10,2)
);

create table products (
	product_id varchar(50),
	product_name varchar(50),
	product_category varchar(50),
	standard_unit_cost numeric(10,2)
);

create table purchase_orders (
	po_number varchar(50),
	supplier_id varchar(50),
	product_id varchar(50),
	quantity_ordered int,
	agreed_unit_price numeric(10,2),
	order_date date,
	promised_delivery_date date

);

create table shipment_modeS(
	mode_id varchar(50),
	mode_name varchar(50)

);

create table suppliers (
	supplier_id varchar(50),
	supplier_name varchar(50),
	supplier_category varchar(50),
	supplier_region varchar(50)

);


-- Load CSVs
COPY deliveries FROM 'E:\supply chain\deliveries.csv' DELIMITER ',' CSV HEADER;
copy products FROM 'E:\supply chain\products.csv' DELIMITER ',' CSV HEADER;
COPY purchase_orders FROM 'E:\supply chain\purchase_orders.csv' DELIMITER ',' CSV HEADER;
COPY shipment_modes FROM 'E:\supply chain\shipment_modes.csv' DELIMITER ',' CSV HEADER;
COPY suppliers FROM 'E:\supply chain\suppliers.csv' DELIMITER ',' CSV HEADER;

SELECT * from purchase_orders
select * from deliveries 
select * from products
select * from  suppliers

--Delivery Delay (Days)
--deleveries- delivery_id, actual_deliver date, t2. purchase_orders-promised_delivery_date
select  
	d.delivery_id,
	d.actual_delivery_date,
	po.order_date,
	po.promised_delivery_date,
	d.actual_delivery_date- po.promised_delivery_date as days_difference	
from deliveries d
inner join purchase_orders po on d.po_number =po.po_number;

--order on-time and full recieve quantity
--t1: purchase_orders    -promised_delivery_date,quantity_ordered
--t2: deleveries         -delivery_id, actual_delivery_date, quantity_received
select 
	d.delivery_id,
	d.actual_delivery_date,
	d.quantity_received,
	po.promised_delivery_date,
	po.quantity_ordered,
	case 
	when d.actual_delivery_date<= po.promised_delivery_date AND d.quantity_received=po.quantity_ordered then 'OTIF'
	else 'Failed' 
	end as OTIF_status
from deliveries d
inner join purchase_orders po on d.po_number =po.po_number;

--cost ooverrun
select 
	d.delivery_id,
	(d.actual_shipping_cost-(po.quantity_ordered*1.20)) as cost_overrun
from deliveries d
inner join purchase_orders po on d.po_number =po.po_number;	










create view supply_chain as (
SELECT  
    d.delivery_id,
    d.po_number,
    s.supplier_name,
    s.supplier_region,
    p.product_name,
    p.product_category,
    sm.mode_name,
    po.order_date,
    po.promised_delivery_date,
    d.actual_delivery_date,
    
    -- 1. Delivery Delay 
    (d.actual_delivery_date - po.promised_delivery_date) AS days_difference,
    
    -- 2. OTIF Status
    CASE 
        WHEN d.actual_delivery_date <=po.promised_delivery_date AND d.quantity_received = po.quantity_ordered THEN 'OTIF'
        ELSE 'Failed'
    END AS otif_status,
    
   
    (d.actual_shipping_cost -(po.quantity_ordered * 1.20)) AS cost_overrun

FROM deliveries d
INNER JOIN purchase_orders po ON d.po_number = po.po_number
INNER JOIN suppliers s ON po.supplier_id = s.supplier_id
INNER JOIN products p ON po.product_id = p.product_id
INNER JOIN shipment_modes sm ON d.mode_id = sm.mode_id
);

select * from supply_chain
limit 5
--Identify High-Risk Suppliers
select
	supplier_name,
	count(*) as total_orders,
	count(*) filter (WHERE otif_status='OTIF') as total_otif_deleveries,
	round(count(*) filter (WHERE otif_status='OTIF')*100/count(*)
	,2) as otif_rate
from supply_chain
group by supplier_name
having (count(*) filter (WHERE otif_status='OTIF')*100/count(*))<70
order by otif_rate


--Worst Shipping Modes for Cost Overruns
select
	mode_name,
	sum (cost_overrun) filter (where cost_overrun > 0)as total_leakage
from supply_chain
group by mode_name
having SUM(cost_overrun) FILTER (WHERE cost_overrun > 0) >0
order by total_leakage desc;

--Late Delivery Leaderboard by Region
select
	supplier_region,
	count(*) as total_orders_in_region,
	round(avg(actual_delivery_date - promised_delivery_date),1)as avg_delay_days
from supply_chain
group by supplier_region
order by avg_delay_days desc;

--Short Shipment Analysis (In-Full Failures)
select
	po.po_number,
	s.supplier_name,
	sum(po.quantity_ordered) as quantity_ordered,
	sum(d.quantity_received)as quantity_received,
	sum(po.quantity_ordered - d.quantity_received )as missing_quantity
from  purchase_orders po
inner join deliveries d on d.po_number = po.po_number
inner join suppliers s ON po.supplier_id = s.supplier_id
WHERE d.actual_delivery_date <= po.promised_delivery_date
group by s.supplier_name, po.po_number
having sum(po.quantity_ordered - d.quantity_received )>0
order by missing_quantity desc;

--Monthly Cost Leakage Trend
select
	extract(year from order_date) as order_year,
	extract(month from order_date) as order_month,
	sum(cost_overrun) as cost_overrun
from supply_chain
WHERE cost_overrun > 0
group by extract(year from order_date),extract(month from order_date) 
order by order_year,order_month




