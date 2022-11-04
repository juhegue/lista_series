import 'package:flutter/material.dart';
import 'package:lista_series/widgets/incrementa_decrementa.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

const _kImageBase64 =
    "iVBORw0KGgoAAAANSUhEUgAAAEsAAABPCAYAAACj3zj8AAABhGlDQ1BJQ0MgcHJvZmlsZQAAKJF9kT1Iw0AcxV+/rGjFwQ4iDhmqkwVREd20CkWoEGqFVh1MLv0QmjQkKS6OgmvBwY/FqoOLs64OroIg+AHi6OSk6CIl/i8ptIjx4Lgf7+497t4B/nqZqWZwFFA1y0gnE0I2tyKEX9GNIDowjZDETH1WFFPwHF/38PH1Ls6zvM/9OXqUvMkAn0A8w3TDIl4nnty0dM77xFFWkhTic+IRgy5I/Mh12eU3zkWH/TwzamTSc8RRYqHYxnIbs5KhEk8QxxRVo3x/1mWF8xZntVxlzXvyF0by2vIS12kOIokFLEKEABlVbKAMC3FaNVJMpGk/4eEfcPwiuWRybYCRYx4VqJAcP/gf/O7WLIyPuUmRBBB6se2PISC8CzRqtv19bNuNEyDwDFxpLX+lDkx9kl5rabEjoHcbuLhuafIecLkD9D/pkiE5UoCmv1AA3s/om3JA3y3Qter21tzH6QOQoa5SN8DBITBcpOw1j3d3tvf275lmfz8+rnKS3lob9QAAAAZiS0dEAPcA9wD3kAU12AAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAAd0SU1FB+YLBAY6I3c4J8AAAAAZdEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIEdJTVBXgQ4XAAAMQklEQVR42u2ae3Cc1XXAf+d+q5Vk2Qbj2LHxA2Ob1nUMONhaWVirx8oWUEIMnUKnybSZSUtIQ9I0ryaQ9OGS0EwnZdpSCCENAdJiYuMwNHFiO9ZbsqQVyDb1QwEqrNiOm4CRX5K12v3u6R/flbRa2cQyNdDJ95vR7Gjvvee7e+6955x7zgchISEhISEhISEhISEhISEhFwMBKKmoQq2cs1OyuS7UFBBxn1OAHwB+TvsA8FIsntiYHx3q2t11gFN9x37jd9ZlauWYU9aJrPY8YLLr95WM6te6Wup/Y5Vlcv7vAaYD0xWZDjoDWAecBu6LIFeFx/DcNipVXJb4oQgbgY8ilAAvA8TKEoIwHxhU4ZedTaN2LRZPAMwBUNUjnW43FpdXg5XLRGwFcCVggV6gM3NZ4eGu57aMyFhdUUUayceyCrjWLeyLRqXVqp9KtjYEMuPVgE4RiAHvc8O7UW3JqAx0tY7Oq6QsgQqzgTyEnytMF6UGmAfUJ5vrOiesrLF7T0B12JadyWopBA4C9UDiLCOHHzwXsKvLa0hrZh2ijwOX5vS13rGBcqAVYGVlBWlfyoDvAovHdBTtAVMJHArsiH4MuN+diCwDI70R4Y7i66uTnTtrs1u2AstQbhbYkDWXz2XN+fyVFYsnEMCoyfPVxoE7gD5VzXWLCmTOITud/c8QmSKBJ5xdvFOgTREfdD6wBpEUwPz58zG+twzY5mzmA8Am4CRwNfBnKjJjWFnuux8AzwE9qhSK8AHgS8Azxtilzoxkz8sCTwGPAU8hWCypiR7DK4cnoSC+2CjwHmAnyiczEdt3wZ5EWQxcAtyvov+WbBpxFN3F5dXbBQVg9oLFqPJ1YBLwcePbb7XvDI5c5aob9/dFBzdGMd7ocunnMaT2d3Vy+nSgk+KyRJcIbwAPqsgN19TUbH5x+/bc3/0dzfO/0FnXeME2Kw28OuwlgQJ33N6H8MEpaX+P200TR3nNSa0R5Duxiqoezze0tdTS2TR6TMRqkYrUAEcKJPVo087WkbaG9q3jdvPrv+hNvWfOApYuj12GsMDNV4DhhV1RMOhvHh8G6DeTE1DU2ZR1GCgPFgyip/NITx6ahsgTwPpBE+27PrHswZ11eyeuKzFHBfsw8AmUblR+5os2xOKJrXh5Wz3Eb2vYisJCd/yePyPRN12YlasTGMMVwEMICbe4udH1NBm/vj5WDr7V0GHEG3a21NG6extqtQ/hXmdr7s6kZ8qFbKzXjx5WxHwKuJHAsBYBnwR+hJ/e5fvpufEbbkZFom7IoMibb2Jj/Hzgp8DNQCPwV8BdwJ84mwVgVMdNOa1m4ifE/LoOnTsbwOqvnLLmZ81fnaH0xk3FV5wyRnj1lW6STTuserJNRD4CshhkEfDtwEjr19P9g6D80slegP110/MqgauAhwT/JuBrnvDo3hfaHwMa3pY4K5uS+BoUe7U7GkdUxB0rrAR2YUHKz4yxBuLJMg2Mef+onARqDcmGHaNRgDE9xfGqz2L1DmCZFd+krHc4X/QgsILAKbySPZ/ieAIEXFw32339QkdLU2A7gFgQe6272MoSQGLxRJ6IoGiRqq4G/sW1PdU3r0ABMidTqbyp+S8Aa/NN5I6S1TWb/Dyjxh+aofBormyFazB2aUm86ocKAybvlPrpqYLVSnelOmzNgL2kMMngmcQ3gIeAjbF44vdEpPfEmVk6peBIROB3UdnjgtleJ/5DxddXPm0jr58xOsOgegvwmYutrMXuaKGqWactiEtEzX2vbPgxAPlTolj4e2AN8LSazOeMzyCwwtmRIzmy5wEbFDkD7LPpqX0CM1103g/cJ+kimhqhrDTvkaFIehXwR8BLqrprasHR02B+290MrgN6fT+v0fPSHcAaMdLj2Rn7gFkukn8IuPtiKGsQ+NZZsg4p5yFrVdlz6NCrI0psb6mnuKKqUazcCNwLLAWOA/9gRO+3Kn+TrW0XHX8FKAOWAAuAY85mPYDQ3bkziL3aOmvtwg+v++NpPX1bgI+6wFOBPcCnxab3AHiFGUtabkJ1vTPyVwPdCLcrWi8qEaAp5zdtAlouOOvwVqh4/y2cKeofleRBsuHs+a/Sqkr8TOCGxKnRGOHEa7/gwIED428SN62F0/6Y6RZMaqNp2wC5dkycUAHesMLLrbVhAi4kJCQkJCTknWS4ulOkVr7tou4vhHXCN8865AN/SFDJCbnQFE3IeaZoYvFEBIgCQ76q7xlZhrIcOI5Qh2i/Fgo6aIzx7fvd/fB/1NAkVlPJ5tGCbKy8GmutMSLz3GW7CPg5qkmx5kzH2AoMkWiU4vLfwk/NnEmQvc1X6BKfbjwiQcpIU8nm+qz70GRWlFxHJC8yR0VKQIsUej0h6asMdjaPPqOkLGFUKAAyyaXxodj+prkgq11z+5SI7d3f8ypHe3vPe2d9xGUE7vRENqK8CDwJ/CdKN1aWSD/TjW9rgedd23ax7AKZPUaS6nIj0kZQPtvs+jYg0que3lpaUT32vrdyGX5q5idcGmYT8O8C+/F4DLjHzWvt2MUtmexFI4+rcAh0M/CkQKNVXhH0htLVVdndh7Md/xTb3/xlkIPA0+6v51TGfHnWknkTOobWfd7rMpIfBqqBRwjqgY8D3wuuz9wO1ADfB34H+Ma1a8ZM7hr3+VnXb42T6wHf960umbF0JQCryqvwvUtrXJplwOWmEsDHgRuAO3MyGpRUVBvQZ1xaZwNwG1DlxuYBz/lGrlldUUPO2JuBTwOfd/0/BrwBfDVvIFpSVnzL+WdKHRnBlJuB6Mn2rq2o/kVdLL77WqAU6LJGV5mMppOtDZSW31jr61AMWFeQknyX5gF4NpMfebJrx/aso1lZi5pmghTwXQumT/3Ma4CPh2DXu5TROvVo6Wyo47rY2vpIvt8IdOVOUK3e5hT5t5jM+mRjk3vG2gbwG1CSwJcyDHwoZ+h7gZUSieztqN/Oyoo1Dcba48BG4A/S+f0dEzXw31PsybYXfoyqJRbfTVZO6JFJU3rSw+V0q2kLtAFFCjOGBezr6jiVN5impCwRiZUlLo/FEwtRsxj4FXAKWDGpP3hDx2hmGrAK2GVVWjpdyqcr+VMEul1ycYw9dN48A/wEG1kUiycWxeKJRai/COU4QT10ldpo7gapF9jbUR8s4vONOyCojA8CV2XXOs53Zx0cW2AWQIervAebfjRqBFMmQ9R6p4JeMgng8vkLmTt/QZ4KXySovMxxRyObS1KTpxvAKrLAfbcnMmIJAvryh7g0Fd0NfDDLHgIsc7+n401+x3EQj7FV9P+O5heODT6FQVXSBDXICSvLTzY3j9v5OXZt5EnkFGLnzp8Hwj8Cn3IG+wmXgR10ff8a8KwacUsRcQLSXVdcPiavOYUCwKZzI2sNvGvaZWPPldRMMT4bbJt3bDmv5Gjk7YhPRCKTFL0L6EZ0BSoDBvCG+snkFxWqck+2/hU56oZeufzQUZJZsryUheA1g1yOEeTf/yPZXHfk/21QqtiZLl5rt0YHks11tDfXkY4WoUoxQdlsVLnWHHE7sBxkVqw6CCtKS0tRlcnOg40wlC4ctjMR4PZYvPLtD0r/r7AirxklA1RJxkwria/ps1gU5kgQhozZ7j4pNeT9M/AAqs8yxJ+WLr5tvx85sVDQB4Fp2f13tW8hFk/8qwsp7gOzv6SiYrvn52GNZcgKEdElwHxEtiebat+9O0t800/wes8VIryk2E0CWwR+5mzXmLdznm9tQdQ+CDzrvOKL/uwTgwT9rwIeHpY8PGZ5c90BFyMVAj9R6+3OiN1glWcjoi8D+4AP6AW+15KtrCGCd5y2jveCbHafuRwAnnGuP5cuN+40QGfrDhDvzwnqjCngVoKy1TfV41b37G2jjkHpaGnI+H7R7xO8G/ZdF8X/pbsqDe/EkWc/Csy6pO5xoMT1fa8LlCuBo8A9An9XaGyWZ+QZYNdZ5j/kFqrxnNb+YrOiogrPd/UqBCM+7U0NZ+1bXFYFIEaMdrg73YpVt2GiJyeJ6j5guhFmtzfV9Y+705ZXj5Tyhz20l1dL21usjr2typoI7hL/nLtSNbsdeS2w3l2sH/Ykcndb0/Z3R9bhHUYJbgAbz9K2DZEvnkqdePekaN5ZVYlvjZYapQq4nuBF2WNAU7J5WfOqsv9ib0dHmGQLCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJOQf/C2N2wGLWCJHEAAAAAElFTkSuQmCC";

class SerieFormPage extends StatefulWidget {
  const SerieFormPage({Key? key}) : super(key: key);

  @override
  State<SerieFormPage> createState() => _SerieFormPageState();
}

class _SerieFormPageState extends State<SerieFormPage> {
  final TextEditingController _nombreController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  int _temporada = 1;
  int _capitulo = 1;
  Uint8List? _imagen;
  bool _vista = false;
  bool _aparcada = false;
  TextEditingController mytext = TextEditingController();

  void getDataFile(file) async {
    var data = await file.readAsBytes();
    setState(() {
      _imagen = data;
    });
  }

  Future getImage(ImageSource media) async {
    try {
      var img = await picker.pickImage(source: media);
      var file = File(img!.path);
      getDataFile(file);
    } on Exception catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Añadir nueva serie'),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Introduzca el nombre de la serie',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  IncrementaDecrementa(
                    titulo: 'Temporada',
                    valor: _temporada.toDouble(),
                    onIncrementa: () {
                      setState(() {
                        _temporada++;
                      });
                    },
                    onDecrementa: () {
                      setState(() {
                        (_temporada > 1) ? _temporada-- : _temporada;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  IncrementaDecrementa(
                    titulo: 'Capítulo',
                    valor: _capitulo.toDouble(),
                    onIncrementa: () {
                      setState(() {
                        _capitulo++;
                      });
                    },
                    onDecrementa: () {
                      setState(() {
                        (_capitulo > 1) ? _capitulo-- : _capitulo;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Esta vista',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Checkbox(
                    value: _vista,
                    onChanged: (bool? value) {
                      setState(() {
                        _vista = value!;
                      });
                    },
                  ),
                  const Text(
                    'Esta aparcada',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Checkbox(
                    value: _aparcada,
                    onChanged: (bool? value) {
                      setState(() {
                        _aparcada = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Imagen',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Visibility(
                      visible: false,
                      child: TextField(
                        controller: mytext,
                      )),
                  MaterialButton(
                    onPressed: () async {
                      getImage(ImageSource.gallery);
                    },
                    child: SizedBox(
                        width: 200.0,
                        height: 200.0,
                        child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: (_imagen != null)
                                ? Image.memory(_imagen!)
                                : Image.memory(base64Decode(_kImageBase64)))),
                  ),
                ])));
  }
}
