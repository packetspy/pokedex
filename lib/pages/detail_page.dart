import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:pokedex/models/layout_type_model.dart';
import 'package:pokedex/models/pokemons_api.model.dart';
import 'package:pokedex/pages/about_page.dart';
import 'package:pokedex/pages/widget/pokemon_type.dart';
import 'package:pokedex/shared/constants.dart';
import 'package:pokedex/stores/pokedex.store.dart';
import 'package:pokedex/stores/pokedexV2.store.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:simple_animations/simple_animations/multi_track_tween.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class DetailPage extends StatefulWidget {
  final int index;

  DetailPage({Key key, this.index}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  PageController _pageController;
  PokedexStore _pokedexStore;
  PokedexV2Store _pokedexV2Store;
  MultiTrackTween _animation;
  double _progress;
  double _multiple;
  double _opacity;
  double _opacityTitleAppBar;
  int _transitionBackround;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.index, viewportFraction: 0.5);
    _pokedexStore = GetIt.instance<PokedexStore>();
    _pokedexV2Store = GetIt.instance<PokedexV2Store>();
    _pokedexV2Store.getInfoPokemon(_pokedexStore.pokemonSelected.name);
    _pokedexV2Store.getInfoSpecie(_pokedexStore.pokemonSelected.id.toString());
    _animation = MultiTrackTween([
      Track('rotateTheBall').add(
          Duration(seconds: 7), Tween(begin: 0.0, end: 1.0),
          curve: Curves.linear)
    ]);
    _progress = 0;
    _multiple = 1;
    _opacity = 1;
    _opacityTitleAppBar = 0;
    _transitionBackround = 300;
  }

  double interval(double lower, double upper, double progress) {
    assert(lower < upper);

    if (progress > upper) return 1.0;
    if (progress < lower) return 0.0;

    return ((progress - lower) / (upper - lower)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Observer(
            builder: (context) {
              return AnimatedContainer(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      _pokedexStore.pokemonSelectedColor,
                      _pokedexStore.pokemonSelectedColor.withOpacity(0.6)
                    ])),
                duration: Duration(milliseconds: _transitionBackround),
                child: Stack(
                  children: <Widget>[
                    AppBar(
                      centerTitle: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.favorite_border),
                          onPressed: () {},
                        )
                      ],
                    ),
                    Positioned(
                      top: (MediaQuery.of(context).size.height * 0.12) -
                          _progress *
                              (MediaQuery.of(context).size.height * 0.060),
                      left: 20 +
                          _progress *
                              ((MediaQuery.of(context).size.height / 3) * 0.60),
                      child: Text(
                        _pokedexStore.pokemonSelected.name,
                        style: TextStyle(
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold,
                            fontSize: 25 -
                                _progress *
                                    (MediaQuery.of(context).size.height *
                                        0.006),
                            color: Colors.white),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.15,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              PokemonType(
                                types: _pokedexStore.pokemonSelected.type,
                                orientation: LayoutType.horizontal,
                              ),
                              Text(
                                "#${_pokedexStore.pokemonSelected.num.toString()}",
                                style: TextStyle(
                                    fontFamily: 'Google',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SlidingSheet(
            listener: (state) {
              setState(() {
                _progress = state.progress;
                _multiple = 1 - interval(0.60, 0.80, _progress);
                _opacity = _multiple;
                _opacityTitleAppBar =
                    _multiple = interval(0.60, 0.80, _progress);
              });
            },
            elevation: 0,
            cornerRadius: 30,
            snapSpec: const SnapSpec(
              snap: true,
              snappings: [0.6, 0.88],
              positioning: SnapPositioning.relativeToAvailableSpace,
            ),
            builder: (context, state) {
              return Container(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).size.height * 0.15,
                child: AboutPage(),
              );
            },
          ),
          Opacity(
            opacity: _opacity,
            child: Padding(
              padding: EdgeInsets.only(
                  top: _opacityTitleAppBar == 1
                      ? 5000
                      : (MediaQuery.of(context).size.height * 0.22) -
                          _progress * 10),
              child: SizedBox(
                height: 200,
                child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      _pokedexStore.setPokemonSelected(index: index);
                      _pokedexV2Store
                          .getInfoPokemon(_pokedexStore.pokemonSelected.name);
                      _pokedexV2Store.getInfoSpecie(
                          _pokedexStore.pokemonSelected.id.toString());
                    },
                    itemCount: _pokedexStore.pokemonsApi.pokemon.length,
                    itemBuilder: (BuildContext context, int index) {
                      Pokemon _pokemonItem =
                          _pokedexStore.getPokemon(index: index);
                      return Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          ControlledAnimation(
                            playback: Playback.LOOP,
                            duration: _animation.duration,
                            tween: _animation,
                            builder: (context, animation) {
                              return Transform.rotate(
                                angle: animation['rotateTheBall'] * 6.3,
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 200),
                                  child: Image.asset(
                                    ConstantsImages.pokeballWhite,
                                    height: 200,
                                    width: 200,
                                  ),
                                  opacity:
                                      index == _pokedexStore.pokemonPosition
                                          ? 0.1
                                          : 0,
                                ),
                              );
                            },
                          ),
                          IgnorePointer(
                            child: Observer(builder: (context) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  AnimatedPadding(
                                    duration: Duration(milliseconds: 400),
                                    curve: Curves.easeInOutCubic,
                                    padding: EdgeInsets.only(
                                        top: index ==
                                                _pokedexStore.pokemonPosition
                                            ? 0
                                            : 60,
                                        bottom: index ==
                                                _pokedexStore.pokemonPosition
                                            ? 0
                                            : 60),
                                    child: Hero(
                                      tag: _pokemonItem.name,
                                      child: CachedNetworkImage(
                                        height: 160,
                                        width: 160,
                                        placeholder: (context, url) =>
                                            new Container(
                                          color: Colors.transparent,
                                        ),
                                        color: index ==
                                                _pokedexStore.pokemonPosition
                                            ? null
                                            : Colors.black.withOpacity(0.5),
                                        imageUrl:
                                            'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${_pokemonItem.num}.png',
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      );
                    }),
              ),
            ),
          )
        ],
      ),
    );
  }
}
