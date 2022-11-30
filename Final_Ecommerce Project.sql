									-- PROJECT TITLE: ECOMMERCE PRODUCTS
                                    
/* SITUATION: CEO is close to securing Maven Fuzzy Factory's next round of funding and needs helps to tell a compelling story to investors
			  You'll need to pull the relevant data and help the CEO craft a story about a data-driven company that has been producing rapid growth

Objective: Extract and analyze traffic and website performance data to craft a growth story that the CEO can sell 
		   Dive in to the marketing channel activities and the website improvements that have contributed to the success to date
           Uisng the opportunity to flex analytical skills 
           1. Tell the story of your company's growth, using trended performance data 
           2. Use the Database to explain how you've been able to produce growth by diving in to channels and website optimizations

Project Questions: 
			1. Show growth volume. Pull overall session and order volume, trended by quarter for the life of the business 
            2. Showcasing all efficiency improvements. Show quarterly figures since launch of business, session-to-order conversion rate, revenue per order and revenue per session 
            3. Specific channel growth. Pull a quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search and direct type-in 
            4. Overall session-to-order conversion rate trends for the channels by Quarter. Make notes of periods where major improvements or optimisations were made 
            5. Monthly trends for revenue and margin by product along with total sales and revenue. Make notes on seasonality 
            6. Deeper dive into the impact of introducing new products. Monthly sessions to the /products page, 
				and show how the percentage of sessions clicking through another page has changed over time 
				Along with a view of how conversion from /products to placing an order has improved 
            7. A 4th product was made available as a primary product on December 05, 2014 (Was previously only a cross-sell item) 
				Pull sales data simce then and show how well each product cross-sells from one another
			8. Based on analysis done, share recommendations and possible opportunities */
            

/* 1. Showing growth volume. 
		Overall Session and Order volume trended by quarter for the life of the business */

SELECT 
	YEAR(website_sessions.created_at) AS YEAR,
    QUARTER(website_sessions.created_at) AS Qtr,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders 
    
FROM website_sessions
LEFT JOIN orders 
	ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2 
ORDER BY 1,2;

/* 2. Showcasing efficiency improvements to show quarterly figures 
	since launch, session-to-order conversion rate, revenue per order, and revenue per session */

SELECT 
	YEAR(website_sessions.created_at) AS YEAR,
    QUARTER(website_sessions.created_at) AS Qtr,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS sessions_to_order_conv_rate,
    SUM(price_usd)/COUNT(DISTINCT orders.order_id) AS revenue_per_order,
    SUM(price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session 
    
FROM website_sessions
LEFT JOIN orders 
	ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2 
ORDER BY 1,2;

/* 3. Channels growth; a quarterly view of orders from 
	Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in */


SELECT 
	YEAR(website_sessions.created_at) AS Yr,
    QUARTER(website_sessions.created_at) AS Qtr,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS organic_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS direct_type_in_orders
    
FROM website_sessions
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2; 
 
/* 4. showing the overall session-to-order conversion rate trends for those same channels, 
by quarter */

SELECT 
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr, 
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rt, 
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rt, 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_search_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_conv_rt
FROM website_sessions 
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

/* 5. Pulling monthly trend for revenue 
	and margin by product, along with total sales and revenue */
 
SELECT 
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items
GROUP BY 1,2
ORDER BY 1,2;
    
/* 6. Pulling monthly sessions to the /products page, and showing how the % of those sessions clicking through another page has changed 
over time, along with a view of how conversion from /products to placing an order has improved */

-- first, identifying all the views of the /products page

CREATE TEMPORARY TABLE products_pageviews
SELECT 
	website_session_id,
    website_pageview_id,
    created_at AS saw_product_page_at
    
FROM website_pageviews
WHERE pageview_url = '/products'
;

SELECT
	YEAR(saw_product_page_at) AS YR,
    MONTH(saw_product_page_at) AS Mo,
    COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page,
    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page,
    COUNT(DISTINCT website_pageviews.website_session_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS clickthrough_rate,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS products_to_order_rt
FROM products_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = products_pageviews.website_session_id
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
	LEFT JOIN orders 
		ON orders.website_session_id = products_pageviews.website_session_id
GROUP BY 1,2;

SHOW VARIABLES LIKE "%timeout";
SET GLOBAL connect_timeout = 200;


/*
7. A 4th product was made available as a primary product on December 05, 2014 (it was previously only a cross-sell item). 
Pull sales data since then, and showing how well each product cross-sells from one another
*/



CREATE TEMPORARY TABLE primary_products
SELECT 
	order_id,
    primary_product_id,
    created_at AS order_at
FROM orders
WHERE created_at > '2014-12-05';

SELECT
	primary_products.*,
    order_items.product_id AS cross_sell_product_id
	
FROM primary_products
	LEFT JOIN order_items
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0;
        
SELECT 
	primary_product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN cross_Sell_product_id = 1 THEN order_id ELSE NULL END) AS _xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_Sell_product_id = 2 THEN order_id ELSE NULL END) AS _xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_Sell_product_id = 3 THEN order_id ELSE NULL END) AS _xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_Sell_product_id = 4 THEN order_id ELSE NULL END) AS _xsold_p4,
    COUNT(DISTINCT CASE WHEN cross_Sell_product_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p1_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_Sell_product_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p2_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_Sell_product_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p3_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_Sell_product_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM 
(
SELECT 
	primary_products.*,
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0
) AS primary_w_cross_sell 
GROUP BY 1;

/*
8. i. Continuing to add Additional products similar to cross products that sold really well
*/



