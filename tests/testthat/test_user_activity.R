source("setup.R")

test_that("Can fetch user activity", {
  skip_on_cran()
  skip_on_travis()
  date_range <- c("2020-01-01","2020-01-02")
  # Get client-ID from e-commerce viewID
  
  cids <- google_analytics(ga_id, date_range = date_range,
                           metrics = c("sessions", "transactionRevenue"), 
                           dimensions = "clientId", 
                           order = order_type("transactionRevenue", "DESCENDING"),
                           max = 5)
  
  expect_s3_class(cids, "data.frame")
  
  users <- ga_clientid_activity(cids$clientId,
                                viewId = ga_id,
                                date_range = date_range)
  expect_s3_class(users, "ga_user_result")
  expect_true(!is.null(users$sessions))
  expect_true(!is.null(users$hits))
  
  unnested <- users$hits %>%
      filter(activityType == "ECOMMERCE") %>%
      select(id, sessionId, activityTime, ecommerce) %>% 
    tidyr::unnest(ecommerce)
  
  one_dude <- unnested[unnested$id == "1065716956.1577466261" ,"ecommerce"][[1]]
  
  expect_equal(one_dude[[1]], "PAYMENT")
  expect_equal(one_dude[[2]]$transactionRevenue, 1471.32)
  expect_equal(one_dude[[3]][[1]]$itemRevenue, 1471.32)
  
  a_hash <- ga_clientid_hash(webPropId, "1065716956.1577466261")
  

})
