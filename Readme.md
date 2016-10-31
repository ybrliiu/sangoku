# NEO三国志NET
CGIゲーム三国志NETを新しく作りなおしたゲームです。  

# next
```      
* 設定ページ作成

* Sangoku::Util methodをRoleに切り出し
* service validate部を適切なRowクラスに移動

* Model::Site 月をまたがる場合や年をまたがる場合は？

* t/ テストするモジュールのload部分をload関数に
* js, scss 外部ファイル化, head読み込みシステム

* Util API, Rowローダは別に必要なさそう？ -> やっぱり必要になりそうである

* Util.pmのメソッド群はRoleに切り出すべきである
 -> Teng::Row がMouseオブジェクトでないのが問題に
    Mouse object化? (速度気にするならTeng::RowをMouse化して書き換え、気にしないならMouseX::Foreignで継承)
* WebSocket, SSL化しないと使えないっぽい
  comet と合わせて活用すべきか(wsで接続できない時cometとか)
  (comet の場合
    comet用のコントローラ作成, 
    model::letterに 新しいメッセージがあるかどうか確認するためだけのメソッド追加
      (直接DBIで叩いて高速化)
    変更があればget()
  )
* plugin -> web 名前空間へ？
* web.pm の処理 外部ファイルに切り出し
* country_position, town country_name SQL見なおすべきか？
* SQLのチューニング
* 書いてないテストも書きましょうね〜〜
* testのコード共通化進める?
* Rowオブジェクトの処理共通化(かなり難しいのでよく考えて)
* outer/regist/complete-regist リロードされた時どうするか
```

# 環境設定方法
```
1. 外部環境設定
2. 依存Perlモジュールインストール
3. 設定ファイル記述(etc/config/db.conf, NYTProf.conf, (Site.conf))
4. perl script/setup.pl
```
