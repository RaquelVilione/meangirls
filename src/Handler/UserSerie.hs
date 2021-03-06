{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies, DeriveGeneric #-}
module Handler.UserSerie where
-- ----------------------------------------------------------------------------------------------------------------------
-- IMPORT
-- ----------------------------------------------------------------------------------------------------------------------
import Control.Monad
import Import 
import Data.Aeson.Types
import Network.HTTP.Types.Status
import Database.Persist.Postgresql
-- ----------------------------------------------------------------------------------------------------------------------
-- GET
-- ----------------------------------------------------------------------------------------------------------------------
getListarSeriesR :: Text -> Handler Value 
getListarSeriesR token = do
    maybeUser <- runDB $ selectFirst [UsuarioToken ==. token] [] 
    case maybeUser of 
        Just (Entity uid usuario) -> do
            seriesId <- runDB $ selectList [UserSerieUserid ==. uid] [] 
            series <- runDB $ mapM (get404 . userSerieSeriid . entityVal) seriesId
            sendStatusJSON ok200 (object ["resp" .= (toJSON series) ]) 
        _ -> do
            sendStatusJSON forbidden403 (object [ "resp" .= ("acao proibida"::Text)])
-- ----------------------------------------------------------------------------------------------------------------------
-- DELETE
-- ----------------------------------------------------------------------------------------------------------------------
deleteDeleteSerieR :: Text -> Int -> Handler Value
deleteDeleteSerieR token apiId = do
    maybeUser <- runDB $ selectFirst [UsuarioToken ==. token] []
    case maybeUser of 
        Just (Entity uid usuario) -> do
            (Entity sid _) <- runDB . getBy404 $ UniqueApi apiId
            [x] <- runDB $ selectKeysList [UserSerieSeriid ==. sid, UserSerieUserid ==. uid] []
            runDB $ delete x
            sendStatusJSON noContent204 emptyObject
        _ -> do
            sendStatusJSON forbidden403 (object [ "resp" .= ("acao proibida"::Text)])
-- ----------------------------------------------------------------------------------------------------------------------
-- 
-- ----------------------------------------------------------------------------------------------------------------------
