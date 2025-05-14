## 注意
本リポジトリのコードは **研究・学習目的** に提供されています。  
**未監査** のため、実運用ウォレットや価値を扱う環境では **絶対に使用しないでください**。  
使用は自己責任でお願いします。

## テストの実行

    npx hardhat test

---

## Gas Report

このリポジトリでは Hardhat のガスレポート機能を利用しています。
下記コマンドでテスト実行と同時にガスレポートを出力できます。

    REPORT_GAS=true
    

## リアルタイムのガス代を計測する場合

リアルタイムでガス代を計測・表示するためには、Gas Priceの取得先となるサービスのAPIキーが必要です。
本リポジトリのサンプルではCoinMarketCapのAPIを使用しています。
hardHat.config.jsで以下のようにCoinMarketCap APIキーを設定してください。

       COINMARKETCAP_API_KEY=YOUR_COINMARKETCAP_API_KEY


