class WordCard extends GetView<WordCardController> {
  WordCard({@required Word word});
  
  @override
  build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black12, offset: Offset(3.0, 6.0), blurRadius: 10.0)
        ]),
        child: AspectRatio(
          aspectRatio: cardAspectRatio,
          child: Stack(
            children: [
              Flip(
                      controller: flipController,
                      flipDirection: Axis.vertical,
                      flipDuration: Duration(milliseconds: 200),
                      secondChild: buildBackCardContent(i, delta),
                      firstChild: buildFrontCardContent(i),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(
                    () => IconButton(
                      splashRadius: 0.01,
                      icon: Icon(Icons.favorite),
                      // key: favoriteButtonKey,
                      color: controller.isWordLiked(controller.wordsList[i])
                          ? Colors.redAccent
                          : Colors.grey,
                      iconSize: BUTTON_SIZE,
                      onPressed: () => controller.toggleFavoriteCard(i),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
