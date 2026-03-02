create database myproject2;
/* KPI's*/
describe fact_bookings;
select * from fact_bookings;
select * from fact_aggregated_bookings;
/* Total Revenue*/
select concat ( round((sum(revenue_realized)/1000000000),2) , 'bn') as "Total Revenue"
from fact_bookings;

/* Total Bookings*/
select concat ( round((count(booking_id)/1000),0) , 'K') as "Total Bookings"
from fact_bookings;

describe fact_aggregated_bookings;
select * from fact_aggregated_bookings;
/* Total Capacity*/
select concat ( round(sum(capacity)/1000,0) , 'K') as "Total Capacity"
from fact_aggregated_bookings;

/* Total Successful Bookings*/
select concat ( round(sum(successful_bookings)/1000,0) , 'K') as "Total Successful Bookings"
from fact_aggregated_bookings;

/* Occupancy %*/
select concat(round(sum(successful_bookings)/sum(capacity) *100,2), '%') as 'Occupancy %'
from fact_aggregated_bookings;

/* Average Rating */
select round(avg(ratings_given),2) as 'Avg Rating'
from fact_bookings;

select * from dim_date;
/* No.of.Days */
select DATEDIFF(max(date), min(date))+1 as 'No.of.Days'
from dim_date;

/* total cancelled bookings */
select concat(round(count(booking_status)/1000 ,2),'K') as 'Total Cancelled Bookings'
from fact_bookings
where booking_status = 'Cancelled';

/*Cancellation % */ 
Select concat(round(
    (Count(Case When booking_status = 'Cancelled' then 1 end) * 100.0) 
    / Count(*),2),'%') as "Cancellation %"
FROM fact_bookings;

/*Total Checked out  */ 
select concat(round(count(booking_status)/1000,2),'K') as 'Total Checked Out'
from fact_bookings
where booking_status = 'Checked Out';

/*Total No Shows  */ 
select concat(round(count(booking_status)/1000,2),'K') as 'Total No Shows'
from fact_bookings
where booking_status = 'No Show';

/*No SHow Rate % */ 
Select concat(round(
    (Count(Case When booking_status = 'No Show' then 1 end) * 100.0) 
    / Count(*),2),'%') as "No Show Rate %"
FROM fact_bookings;


/*Average Daily Rate*/ 
Select Concat(Round(sum(revenue_realized)/count(booking_id),0), 'K') AS "ADR"
FROM fact_bookings;

/*Realization % */ 
Select concat(round(
    (Count(Case When booking_status = 'Checked Out' then 1 end) * 100.0) 
    / Count(*),2),'%') as "Realization %"
FROM fact_bookings;

select * from dim_rooms;
/*Booking% by Room CLass*/
Select dr.room_class,
    concat (Round(Count(fb.booking_id) * 100.0 / (Select Count(*) from fact_bookings), 2), '%') as "Booking % by Room class"
from fact_bookings fb
join dim_rooms dr on fb.room_category = dr.room_id 
group by dr.room_class;
    
    /*DBRN - Daily Booked Room Nights */
  select count(fb.booking_id)/count(distinct dd.date) as 'DBRN'
  from
  fact_bookings fb
  join 
  dim_date dd on fb.check_in_date = dd.date;

    /*DSRN - Daily Sellable Room Nights */
  select round((count(fab.capacity)/count(distinct dd.date)),2) as 'DSRN'
  from
  fact_aggregated_bookings fab
  join 
  dim_date dd on fab.check_in_date = dd.date;
  
  /* Revenue WOW change% */
  select year(check_in_date) as Curr_Year, week(check_in_date) as Week_No, sum(revenue_realized) as CW_Tot_Revenue,
  lag(CW_Tot_revenue,1) over(order by curr_year, week_no) as PW_Tot_Revenue
  from fact_bookings;
  
  /*Weekend/Weekday wise Revenue */
  select dd.day_type, concat(round((sum(fb.revenue_realized)/100000000),2),'bn') as Tot_Revenue
  from dim_date dd
  inner join fact_bookings fb on dd.date = fb.check_in_date
  group by dd.Day_type;
  
  /*Weekend/Weekday wise Booking */
  select dd.day_type, concat(round((count(fb.booking_id)/1000),2),'K') as Tot_Bookings
  from fact_bookings fb
  join dim_date dd on fb.check_in_date = dd.date
  group by dd.Day_type;
  
  /*Revenue by City */
  select dh.city, concat(round((sum(fb.revenue_realized)/100000000),2),'bn') as Tot_Revenue
  from dim_hotels dh
  join fact_bookings fb on dh.property_id = fb.property_id
  group by dh.city;
  
  /*Revenue by Property */
  select dh.property_name, concat(round((sum(fb.revenue_realized)/100000000),2),'bn') as Tot_Revenue
  from dim_hotels dh
  join fact_bookings fb on dh.property_id = fb.property_id
  group by dh.property_name;
  
  /*CLass wise Revenue*/
Select dr.room_class,
    concat (Round((sum(revenue_realized)/1000000000), 2), 'bn') as Tot_Revenue
from dim_rooms dr
join fact_bookings fb on dr.room_id = fb.room_category
group by dr.room_class;

/*Booking status % */
Select booking_status , concat (Round(Count(booking_status) * 100.0 / (Select Count(*) from fact_bookings), 2), '%') as "Booking_status % "
from fact_bookings 
group by booking_status;

/*Weekly Booking Trends based on room class*/
select dd.week no , dr.room_class, count(fb.booking_id) as Tot_Bookings
from fact_bookings fb
join dim_rooms dr on fb.room_category = dr.room_id
join dim_date dd on fb.check_in_date = dd.date
group by dd.week no, dr.room_class
order by dd.week no;

/*Weekly Revenue Trends based on room class*/
select dd.week no , dr.room_class, sum(fb.revenue_realized) as Tot_Revenue
from fact_bookings fb
join dim_rooms dr on fb.room_category = dr.room_id
join dim_date dd on fb.check_in_date = dd.date
group by dd.week no, dr.room_class
order by dd.week no;

/*Weekly Occupancy Trends based on room class*/
select dd.week_num , dr.room_class, concat(round(sum(fab.successful_bookings)/sum(fab.capacity) *100,2), '%') as 'Occupancy %'
from fact_aggregated_bookings fab
join dim_rooms dr on fab.room_category = dr.room_id
join dim_date dd on fab.check_in_date = dd.date
group by dd.week_num, dr.room_class
order by dd.week_num, dr.room_class;