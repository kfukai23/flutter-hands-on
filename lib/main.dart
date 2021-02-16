import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import宣言を追加する
import 'package:flutter_hands_on/stores/product_list_store.dart';
import 'package:provider/provider.dart';

void main() async {
  await DotEnv().load('.env');
  // MultiProviderも、ウィジェットの一種
  runApp(MultiProvider(
    // MultiProviderは複数のChangeNotifierProviderを格納できるProviderのこと
    // providersにList<ChangeNotifierProvider>を指定する
    providers: [
      // ChangeNotifierProviderはcreateにデリゲートを取り、この中でChangeNotifierを初期化して返す
      ChangeNotifierProvider(
        create: (context) => ProductListStore(),
      )
    ],
    // childにはもともと表示に使っていたウィジェットを配置する
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // addPostFrameCallbackは、initStateが呼ばれた後に一度のみ実行されるコールバック
    // ウィジェットの描画を行う際、最初の一度のみ実行したい処理を記述する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<T>()メソッドでstoreへの参照を取得する
      // Tには、取得したいChangeNotifierのクラスタイプを指定する、今回はProductListStore
      // readは、ChangeNotifierのnotifyListeners()が呼ばれてもウィジェットのリビルドフラグを有効にしない
      // 副作用を伴うアクションを呼ぶ場合は、必ずbuildメソッドの外でreadを使う
      final store = context.read<ProductListStore>();
      if (store.products.isEmpty) {
        store.fetchNextProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SUZURI"),
      ),
      body: _productsList(context),
    );
  }

  Widget _productsList(BuildContext context) {
    // storeの参照を取得
    // ここではStoreに変更があったらウィジェットに反映したいのでwatchを使う
    final store = context.watch<ProductListStore>();
    final products = store.products;
    // Storeから取得できた商品の数を見て、表示すべきウィジェットを変える
    // 具体的には、0件→空っぽのリスト、1件以上→実際の商品リスト
    if (products.isEmpty) {
      return Container(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.grey,
              margin: EdgeInsets.all(16),
            );
          },
        ),
      );
    } else {
      // 商品のウィジェットをまだ作っていないので、仮でTextを表示してみる
      return Center(child: Text("products"));
    }
  }
}
