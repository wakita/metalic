---
title: "三角形を描画する基本的な例"
author: "Ken Wakita"
date: "November 13, 2018"
---

参考資料
: [Rendering graphics with MetalKit Swift4 (Part 1)](https://www.clientresourcesinc.com/2018/04/30/rendering-graphics-with-metalkit-swift-4-part-1/)

実行例
: ![実行例](https://gyazo.com/9b5bae985bf4246e56f8c5af9288d8fb.png)

---

# 反省

頂点バッファを準備するところで、つまらないミスをした。気づくまでにかなり苦労した。本来、以下が正しい。

`vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: [])`

それに対して以下のように頂点の個数を乗ずるのを忘れていたのが敗因。

`vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride, options: [])`

この結果、バッファには最初の1頂点分のデータだけが供給された。当然、三角形を描くには少なくとも3頂点分のデータが必要なので、これでは足りない。このため画面には何も描かれなかった。

バッファにデータが足りないことの確認は、GPU デバッガでバッファの内容を眺めるのが最も簡単だと思う。このことに気づけば  `makeBuffer` の引数に問題があることに思いが至るだろう。
