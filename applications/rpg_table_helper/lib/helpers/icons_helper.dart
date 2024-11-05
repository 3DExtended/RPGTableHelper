import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rpg_table_helper/components/custom_fa_icon.dart';

const allIconNames = [
  "anchor",
  "biohazard",
  "bolt",
  "bolt-lightning",
  "bomb",
  "bone",
  "book",
  "book-open",
  "broom",
  "burst",
  "campground",
  "carrot",
  "cat",
  "chess-rook",
  "chess-king",
  "chess-queen",
  "chess-knight",
  "circle-radiation",
  "clock",
  "cloud-bolt",
  "cloud-moon",
  "cloud-showers-heavy",
  "cloud-sun",
  "clover",
  "comment",
  "comments",
  "compass",
  "compass-drafting",
  "cow",
  "cross",
  "crosshairs",
  "crow",
  "crown",
  "dice",
  "dice-d20",
  "dice-six",
  "dog",
  "dove",
  "dragon",
  "droplet",
  "drumstick-bite",
  "dungeon",
  "earth-europe",
  "egg",
  "envelope",
  "explosion",
  "eye",
  "feather",
  "feather-pointed",
  "file",
  "fingerprint",
  "fire",
  "fire-flame-curved",
  "fish-fins",
  "flag",
  "flask",
  "frog",
  "gavel",
  "gear",
  "gears",
  "gem",
  "ghost",
  "gift",
  "glasses",
  "gun",
  "hammer",
  "hand-holding-heart",
  "hand-holding-medical",
  "hat-cowboy",
  "hat-wizard",
  "heart",
  "heart-circle-bolt",
  "helicopter",
  "hippo",
  "horse",
  "hourglass",
  "hourglass-half",
  "house-chimney",
  "house",
  "ice-cream",
  "igloo",
  "industry",
  "infinity",
  "jet-fighter",
  "jet-fighter-up",
  "key",
  "kiwi-bird",
  "landmark",
  "leaf",
  "lemon",
  "lightbulb",
  "link",
  "link-slash",
  "list",
  "list-check",
  "location-arrow",
  "location-crosshairs",
  "location-dot",
  "lock",
  "lock-open",
  "magnifying-glass",
  "map",
  "map-location-dot",
  "martini-glass",
  "medal",
  "meteor",
  "microchip",
  "microphone",
  "microphone-slash",
  "moon",
  "mortar-pestle",
  "mosque",
  "motorcycle",
  "mountain",
  "mountain-sun",
  "music",
  "otter",
  "paintbrush",
  "palette",
  "paw",
  "pen-nib",
  "people-group",
  "pepper-hot",
  "person-running",
  "person-swimming",
  "piggy-bank",
  "place-of-worship",
  "plane",
  "puzzle-piece",
  "radiation",
  "receipt",
  "robot",
  "rocket",
  "sailboat",
  "scale-balanced",
  "screwdriver-wrench",
  "seedling",
  "shield",
  "shield-halved",
  "shield-heart",
  "shoe-prints",
  "shop",
  "shrimp",
  "shuttle-space",
  "skull",
  "skull-crossbones",
  "snowflake",
  "spider",
  "star",
  "store",
  "sun",
  "tag",
  "tent",
  "tents",
  "tooth",
  "tree",
  "trophy",
  "user-shield",
  "wand-magic-sparkles",
  "wand-sparkles",
  "yin-yang",

  // -------
  "backpack-svgrepo-com-2",
  "armoury-body-svgrepo-com",
  "axe-svgrepo-com",
  "backpack-luggage-svgrepo-com",
  "backpack-svgrepo-com",
  "bat-svgrepo-com",
  "black-cat-pet-svgrepo-com",
  "bow-and-arrow-svgrepo-com",
  "castle-svgrepo-com-2",
  "castle-svgrepo-com",
  "castle-with-three-towers-svgrepo-com",
  "catalyst-svgrepo-com",
  "cauldron-svgrepo-com",
  "creepy-devil-evil-pentagram-scary-svgrepo-com",
  "crossbow-svgrepo-com",
  "culture-glass-ball-looking-svgrepo-com",
  "goblet-svgrepo-com",
  "halloween-bones-stew-in-a-pot-outline-svgrepo-com",
  "halloween-potion-svgrepo-com",
  "helmet-svgrepo-com",
  "jewelry-store-svgrepo-com",
  "key-svgrepo-com",
  "mace-svgrepo-com",
  "magic-ball-future-svgrepo-com",
  "magic-wand-svgrepo-com",
  "magic-wand-witch-svgrepo-com",
  "money-bag-svgrepo-com",
  "plant-botanical-svgrepo-com",
  "plant-leaf-svgrepo-com",
  "potion-svgrepo-com",
  "rum-svgrepo-com",
  "sand-castle-castle-svgrepo-com",
  "skull-and-bones-svgrepo-com",
  "skull-svgrepo-com",
  "spellbook-legend-svgrepo-com",
  "spellbook-svgrepo-com",
  "sword-svgrepo-com-2",
  "sword-svgrepo-com-3",

  "sword-svgrepo-com",
  "tools-svgrepo-com",
  "treasure-chest-free-illustration-4-svgrepo-com",
  "treasure-map-svgrepo-com-2",
  "treasure-map-svgrepo-com",
  "vault-weapons-svgrepo-com",
  "weapon-fantasy-spell-book-magig-svgrepo-com",
  "viking-svgrepo-com",
  "flask-laboratory-svgrepo-com",
];

(String, Widget) getIconForIdentifier(
    {required String name, double? size, Color? color}) {
  switch (name) {
    case "backpack-svgrepo-com-2":
      return (
        "backpack-svgrepo-com-2",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/backpack-svgrepo-com-2.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "flask-laboratory-svgrepo-com":
      return (
        "flask-laboratory-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/flask-laboratory-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "armoury-body-svgrepo-com":
      return (
        "armoury-body-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/armoury-body-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "axe-svgrepo-com":
      return (
        "axe-svgrepo-com",
        SvgPicture.asset("assets/icons/inappcategoryicons/axe-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "backpack-luggage-svgrepo-com":
      return (
        "backpack-luggage-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/backpack-luggage-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "backpack-svgrepo-com":
      return (
        "backpack-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/backpack-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "bat-svgrepo-com":
      return (
        "bat-svgrepo-com",
        SvgPicture.asset("assets/icons/inappcategoryicons/bat-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "black-cat-pet-svgrepo-com":
      return (
        "black-cat-pet-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/black-cat-pet-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "bow-and-arrow-svgrepo-com":
      return (
        "bow-and-arrow-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/bow-and-arrow-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "castle-svgrepo-com-2":
      return (
        "castle-svgrepo-com-2",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/castle-svgrepo-com-2.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "castle-svgrepo-com":
      return (
        "castle-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/castle-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "castle-with-three-towers-svgrepo-com":
      return (
        "castle-with-three-towers-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/castle-with-three-towers-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "catalyst-svgrepo-com":
      return (
        "catalyst-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/catalyst-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "cauldron-svgrepo-com":
      return (
        "cauldron-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/cauldron-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "creepy-devil-evil-pentagram-scary-svgrepo-com":
      return (
        "creepy-devil-evil-pentagram-scary-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/creepy-devil-evil-pentagram-scary-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "crossbow-svgrepo-com":
      return (
        "crossbow-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/crossbow-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "culture-glass-ball-looking-svgrepo-com":
      return (
        "culture-glass-ball-looking-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/culture-glass-ball-looking-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "goblet-svgrepo-com":
      return (
        "goblet-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/goblet-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "halloween-bones-stew-in-a-pot-outline-svgrepo-com":
      return (
        "halloween-bones-stew-in-a-pot-outline-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/halloween-bones-stew-in-a-pot-outline-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "halloween-potion-svgrepo-com":
      return (
        "halloween-potion-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/halloween-potion-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "helmet-svgrepo-com":
      return (
        "helmet-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/helmet-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "jewelry-store-svgrepo-com":
      return (
        "jewelry-store-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/jewelry-store-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "key-svgrepo-com":
      return (
        "key-svgrepo-com",
        SvgPicture.asset("assets/icons/inappcategoryicons/key-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "mace-svgrepo-com":
      return (
        "mace-svgrepo-com",
        SvgPicture.asset("assets/icons/inappcategoryicons/mace-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "magic-ball-future-svgrepo-com":
      return (
        "magic-ball-future-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/magic-ball-future-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "magic-wand-svgrepo-com":
      return (
        "magic-wand-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/magic-wand-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "magic-wand-witch-svgrepo-com":
      return (
        "magic-wand-witch-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/magic-wand-witch-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "money-bag-svgrepo-com":
      return (
        "money-bag-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/money-bag-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "plant-botanical-svgrepo-com":
      return (
        "plant-botanical-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/plant-botanical-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "plant-leaf-svgrepo-com":
      return (
        "plant-leaf-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/plant-leaf-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "potion-svgrepo-com":
      return (
        "potion-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/potion-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "rum-svgrepo-com":
      return (
        "rum-svgrepo-com",
        SvgPicture.asset("assets/icons/inappcategoryicons/rum-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "sand-castle-castle-svgrepo-com":
      return (
        "sand-castle-castle-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/sand-castle-castle-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "skull-and-bones-svgrepo-com":
      return (
        "skull-and-bones-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/skull-and-bones-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "skull-svgrepo-com":
      return (
        "skull-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/skull-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "spellbook-legend-svgrepo-com":
      return (
        "spellbook-legend-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/spellbook-legend-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "spellbook-svgrepo-com":
      return (
        "spellbook-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/spellbook-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "sword-svgrepo-com-2":
      return (
        "sword-svgrepo-com-2",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/sword-svgrepo-com-2.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "sword-svgrepo-com-3":
      return (
        "sword-svgrepo-com-3",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/sword-svgrepo-com-3.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "sword-svgrepo-com":
      return (
        "sword-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/sword-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "tools-svgrepo-com":
      return (
        "tools-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/tools-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "treasure-chest-free-illustration-4-svgrepo-com":
      return (
        "treasure-chest-free-illustration-4-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/treasure-chest-free-illustration-4-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "treasure-map-svgrepo-com-2":
      return (
        "treasure-map-svgrepo-com-2",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/treasure-map-svgrepo-com-2.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "treasure-map-svgrepo-com":
      return (
        "treasure-map-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/treasure-map-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );
    case "vault-weapons-svgrepo-com":
      return (
        "vault-weapons-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/vault-weapons-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );

    case "weapon-fantasy-spell-book-magig-svgrepo-com":
      return (
        "weapon-fantasy-spell-book-magig-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/weapon-fantasy-spell-book-magig-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );

    case "viking-svgrepo-com":
      return (
        "viking-svgrepo-com",
        SvgPicture.asset(
            "assets/icons/inappcategoryicons/viking-svgrepo-com.svg",
            colorFilter:
                color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size)
      );

//------------
//------------
//------------
//------------
//------------
//------------
//------------

    case "anchor":
      return (
        "anchor",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.anchor)
      ); // ?f=classic&s=solid
    case "biohazard":
      return (
        "biohazard",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.biohazard)
      ); // ?f=classic&s=solid
    case "bolt":
      return (
        "bolt",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.bolt)
      ); // ?f=classic&s=solid
    case "bolt-lightning":
      return (
        "bolt-lightning",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.boltLightning)
      ); // ?f=classic&s=solid
    case "bomb":
      return (
        "bomb",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.bomb)
      ); // ?f=classic&s=solid
    case "bone":
      return (
        "bone",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.bone)
      ); // ?f=classic&s=solid
    case "book":
      return (
        "book",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.book)
      ); // ?f=classic&s=solid
    case "book-open":
      return (
        "book-open",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.bookOpen)
      ); // ?f=classic&s=solid
    case "broom":
      return (
        "broom",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.broom)
      ); // ?f=classic&s=solid
    case "burst":
      return (
        "burst",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.burst)
      ); // ?f=classic&s=solid
    case "campground":
      return (
        "campground",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.campground)
      ); // ?f=classic&s=solid
    case "carrot":
      return (
        "carrot",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.carrot)
      ); // ?f=classic&s=solid
    case "cat":
      return (
        "cat",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.cat)
      ); // ?f=classic&s=solid
    case "chess-rook":
      return (
        "chess-rook",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.chessRook)
      ); // ?f=classic&s=solid
    case "chess-king":
      return (
        "chess-king",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.chessKing)
      ); // ?f=classic&s=solid
    case "chess-queen":
      return (
        "chess-queen",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.chessQueen)
      ); // ?f=classic&s=solid
    case "chess-knight":
      return (
        "chess-knight",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.chessKnight)
      ); // ?f=classic&s=solid
    case "circle-radiation":
      return (
        "circle-radiation",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.circleRadiation)
      ); // ?f=classic&s=solid
    case "clock":
      return (
        "clock",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.clock)
      ); // ?f=classic&s=solid
    case "cloud-bolt":
      return (
        "cloud-bolt",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.cloudBolt)
      ); // ?f=classic&s=solid
    case "cloud-moon":
      return (
        "cloud-moon",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.cloudMoon)
      ); // ?f=classic&s=solid
    case "cloud-showers-heavy":
      return (
        "cloud-showers-heavy",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.cloudShowersHeavy)
      ); // ?f=classic&s=solid
    case "cloud-sun":
      return (
        "cloud-sun",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.cloudSun)
      ); // ?f=classic&s=solid
    case "clover":
      return (
        "clover",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.clover)
      ); // ?f=classic&s=solid
    case "comment":
      return (
        "comment",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.comment)
      ); // ?f=classic&s=solid
    case "comments":
      return (
        "comments",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.comments)
      ); // ?f=classic&s=solid
    case "compass":
      return (
        "compass",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.compass)
      ); // ?f=classic&s=solid
    case "compass-drafting":
      return (
        "compass-drafting",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.compassDrafting)
      ); // ?f=classic&s=solid
    case "cow":
      return (
        "cow",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.cow)
      ); // ?f=classic&s=solid
    case "cross":
      return (
        "cross",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.cross)
      ); // ?f=classic&s=solid
    case "crosshairs":
      return (
        "crosshairs",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.crosshairs)
      ); // ?f=classic&s=solid
    case "crow":
      return (
        "crow",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.crow)
      ); // ?f=classic&s=solid
    case "crown":
      return (
        "crown",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.crown)
      ); // ?f=classic&s=solid
    case "dice":
      return (
        "dice",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.dice)
      ); // ?f=classic&s=solid
    case "dice-d20":
      return (
        "dice-d20",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.diceD20)
      ); // ?f=classic&s=solid
    case "dice-six":
      return (
        "dice-six",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.diceSix)
      ); // ?f=classic&s=solid
    case "dog":
      return (
        "dog",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.dog)
      ); // ?f=classic&s=solid
    case "dove":
      return (
        "dove",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.dove)
      ); // ?f=classic&s=solid
    case "dragon":
      return (
        "dragon",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.dragon)
      ); // ?f=classic&s=solid
    case "droplet":
      return (
        "droplet",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.droplet)
      ); // ?f=classic&s=solid
    case "drumstick-bite":
      return (
        "drumstick-bite",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.drumstickBite)
      ); // ?f=classic&s=solid
    case "dungeon":
      return (
        "dungeon",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.dungeon)
      ); // ?f=classic&s=solid
    case "earth-europe":
      return (
        "earth-europe",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.earthEurope)
      ); // ?f=classic&s=solid
    case "egg":
      return (
        "egg",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.egg)
      ); // ?f=classic&s=solid
    case "envelope":
      return (
        "envelope",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.envelope)
      ); // ?f=classic&s=solid
    case "explosion":
      return (
        "explosion",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.explosion)
      ); // ?f=classic&s=solid
    case "eye":
      return (
        "eye",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.eye)
      ); // ?f=classic&s=solid
    case "feather":
      return (
        "feather",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.feather)
      ); // ?f=classic&s=solid
    case "feather-pointed":
      return (
        "feather-pointed",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.featherPointed)
      ); // ?f=classic&s=solid
    case "file":
      return (
        "file",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.file)
      ); // ?f=classic&s=solid
    case "fingerprint":
      return (
        "fingerprint",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.fingerprint)
      ); // ?f=classic&s=solid
    case "fire":
      return (
        "fire",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.fire)
      ); // ?f=classic&s=solid
    case "fire-flame-curved":
      return (
        "fire-flame-curved",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.fireFlameCurved)
      ); // ?f=classic&s=solid
    case "fish-fins":
      return (
        "fish-fins",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.fishFins)
      ); // ?f=classic&s=solid
    case "flag":
      return (
        "flag",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.flag)
      ); // ?f=classic&s=solid
    case "flask":
      return (
        "flask",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.flask)
      ); // ?f=classic&s=solid
    case "frog":
      return (
        "frog",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.frog)
      ); // ?f=classic&s=solid
    case "gavel":
      return (
        "gavel",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.gavel)
      ); // ?f=classic&s=solid
    case "gear":
      return (
        "gear",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.gear)
      ); // ?f=classic&s=solid
    case "gears":
      return (
        "gears",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.gears)
      ); // ?f=classic&s=solid
    case "gem":
      return (
        "gem",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.gem)
      ); // ?f=classic&s=solid
    case "ghost":
      return (
        "ghost",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.ghost)
      ); // ?f=classic&s=solid
    case "gift":
      return (
        "gift",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.gift)
      ); // ?f=classic&s=solid
    case "glasses":
      return (
        "glasses",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.glasses)
      ); // ?f=classic&s=solid
    case "gun":
      return (
        "gun",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.gun)
      ); // ?f=classic&s=solid
    case "hammer":
      return (
        "hammer",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.hammer)
      ); // ?f=classic&s=solid
    case "hand-holding-heart":
      return (
        "hand-holding-heart",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.handHoldingHeart)
      ); // ?f=classic&s=solid
    case "hand-holding-medical":
      return (
        "hand-holding-medical",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.handHoldingMedical)
      ); // ?f=classic&s=solid
    case "hat-cowboy":
      return (
        "hat-cowboy",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.hatCowboy)
      ); // ?f=classic&s=solid
    case "hat-wizard":
      return (
        "hat-wizard",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.hatWizard)
      ); // ?f=classic&s=solid
    case "heart":
      return (
        "heart",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.heart)
      ); // ?f=classic&s=solid
    case "heart-circle-bolt":
      return (
        "heart-circle-bolt",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.heartCircleBolt)
      ); // ?f=classic&s=solid
    case "helicopter":
      return (
        "helicopter",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.helicopter)
      ); // ?f=classic&s=solid
    case "hippo":
      return (
        "hippo",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.hippo)
      ); // ?f=classic&s=solid
    case "horse":
      return (
        "horse",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.horse)
      ); // ?f=classic&s=solid
    case "hourglass":
      return (
        "hourglass",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.hourglass)
      ); // ?f=classic&s=solid
    case "hourglass-half":
      return (
        "hourglass-half",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.hourglassHalf)
      ); // ?f=classic&s=solid
    case "house-chimney":
      return (
        "house-chimney",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.houseChimney)
      ); // ?f=classic&s=solid
    case "house":
      return (
        "house",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.house)
      ); // ?f=classic&s=solid
    case "ice-cream":
      return (
        "ice-cream",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.iceCream)
      ); // ?f=classic&s=solid
    case "igloo":
      return (
        "igloo",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.igloo)
      ); // ?f=classic&s=solid
    case "industry":
      return (
        "industry",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.industry)
      ); // ?f=classic&s=solid
    case "infinity":
      return (
        "infinity",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.infinity)
      ); // ?f=classic&s=solid
    case "jet-fighter":
      return (
        "jet-fighter",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.jetFighter)
      ); // ?f=classic&s=solid
    case "jet-fighter-up":
      return (
        "jet-fighter-up",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.jetFighterUp)
      ); // ?f=classic&s=solid
    case "key":
      return (
        "key",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.key)
      ); // ?f=classic&s=solid
    case "kiwi-bird":
      return (
        "kiwi-bird",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.kiwiBird)
      ); // ?f=classic&s=solid
    case "landmark":
      return (
        "landmark",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.landmark)
      ); // ?f=classic&s=solid
    case "leaf":
      return (
        "leaf",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.leaf)
      ); // ?f=classic&s=solid
    case "lemon":
      return (
        "lemon",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.lemon)
      ); // ?f=classic&s=solid
    case "lightbulb":
      return (
        "lightbulb",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.lightbulb)
      ); // ?f=classic&s=solid
    case "link":
      return (
        "link",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.link)
      ); // ?f=classic&s=solid
    case "link-slash":
      return (
        "link-slash",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.linkSlash)
      ); // ?f=classic&s=solid
    case "list":
      return (
        "list",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.list)
      ); // ?f=classic&s=solid
    case "list-check":
      return (
        "list-check",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.listCheck)
      ); // ?f=classic&s=solid
    case "location-arrow":
      return (
        "location-arrow",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.locationArrow)
      ); // ?f=classic&s=solid
    case "location-crosshairs":
      return (
        "location-crosshairs",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.locationCrosshairs)
      ); // ?f=classic&s=solid
    case "location-dot":
      return (
        "location-dot",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.locationDot)
      ); // ?f=classic&s=solid
    case "lock":
      return (
        "lock",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.lock)
      ); // ?f=classic&s=solid
    case "lock-open":
      return (
        "lock-open",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.lockOpen)
      ); // ?f=classic&s=solid
    case "magnifying-glass":
      return (
        "magnifying-glass",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.magnifyingGlass)
      ); // ?f=classic&s=solid
    case "map":
      return (
        "map",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.map)
      ); // ?f=classic&s=solid
    case "map-location-dot":
      return (
        "map-location-dot",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.mapLocationDot)
      ); // ?f=classic&s=solid
    case "martini-glass":
      return (
        "martini-glass",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.martiniGlass)
      ); // ?f=classic&s=solid
    case "medal":
      return (
        "medal",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.medal)
      ); // ?f=classic&s=solid
    case "meteor":
      return (
        "meteor",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.meteor)
      ); // ?f=classic&s=solid
    case "microchip":
      return (
        "microchip",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.microchip)
      ); // ?f=classic&s=solid
    case "microphone":
      return (
        "microphone",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.microphone)
      ); // ?f=classic&s=solid
    case "microphone-slash":
      return (
        "microphone-slash",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.microphoneSlash)
      ); // ?f=classic&s=solid
    case "moon":
      return (
        "moon",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.moon)
      ); // ?f=classic&s=solid
    case "mortar-pestle":
      return (
        "mortar-pestle",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.mortarPestle)
      ); // ?f=classic&s=solid
    case "mosque":
      return (
        "mosque",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.mosque)
      ); // ?f=classic&s=solid
    case "motorcycle":
      return (
        "motorcycle",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.motorcycle)
      ); // ?f=classic&s=solid
    case "mountain":
      return (
        "mountain",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.mountain)
      ); // ?f=classic&s=solid
    case "mountain-sun":
      return (
        "mountain-sun",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.mountainSun)
      ); // ?f=classic&s=solid
    case "music":
      return (
        "music",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.music)
      ); // ?f=classic&s=solid
    case "otter":
      return (
        "otter",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.otter)
      ); // ?f=classic&s=solid
    case "paintbrush":
      return (
        "paintbrush",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.paintbrush)
      ); // ?f=classic&s=solid
    case "palette":
      return (
        "palette",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.palette)
      ); // ?f=classic&s=solid
    case "paw":
      return (
        "paw",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.paw)
      ); // ?f=classic&s=solid
    case "pen-nib":
      return (
        "pen-nib",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.penNib)
      ); // ?f=classic&s=solid
    case "people-group":
      return (
        "people-group",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.peopleGroup)
      ); // ?f=classic&s=solid
    case "pepper-hot":
      return (
        "pepper-hot",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.pepperHot)
      ); // ?f=classic&s=solid
    case "person-running":
      return (
        "person-running",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.personRunning)
      ); // ?f=classic&s=solid
    case "person-swimming":
      return (
        "person-swimming",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.personSwimming)
      ); // ?f=classic&s=solid
    case "piggy-bank":
      return (
        "piggy-bank",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.piggyBank)
      ); // ?f=classic&s=solid
    case "place-of-worship":
      return (
        "place-of-worship",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.placeOfWorship)
      ); // ?f=classic&s=solid
    case "plane":
      return (
        "plane",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.plane)
      ); // ?f=classic&s=solid
    case "puzzle-piece":
      return (
        "puzzle-piece",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.puzzlePiece)
      ); // ?f=classic&s=solid
    case "radiation":
      return (
        "radiation",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.radiation)
      ); // ?f=classic&s=solid
    case "receipt":
      return (
        "receipt",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.receipt)
      ); // ?f=classic&s=solid
    case "robot":
      return (
        "robot",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.robot)
      ); // ?f=classic&s=solid
    case "rocket":
      return (
        "rocket",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.rocket)
      ); // ?f=classic&s=solid
    case "sailboat":
      return (
        "sailboat",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.sailboat)
      ); // ?f=classic&s=solid
    case "scale-balanced":
      return (
        "scale-balanced",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.scaleBalanced)
      ); // ?f=classic&s=solid
    case "screwdriver-wrench":
      return (
        "screwdriver-wrench",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.screwdriverWrench)
      ); // ?f=classic&s=solid
    case "seedling":
      return (
        "seedling",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.seedling)
      ); // ?f=classic&s=solid
    case "shield":
      return (
        "shield",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.shield)
      ); // ?f=classic&s=solid
    case "shield-halved":
      return (
        "shield-halved",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.shieldHalved)
      ); // ?f=classic&s=solid
    case "shield-heart":
      return (
        "shield-heart",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.shieldHeart)
      ); // ?f=classic&s=solid
    case "shoe-prints":
      return (
        "shoe-prints",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.shoePrints)
      ); // ?f=classic&s=solid
    case "shop":
      return (
        "shop",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.shop)
      ); // ?f=classic&s=solid
    case "shrimp":
      return (
        "shrimp",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.shrimp)
      ); // ?f=classic&s=solid
    case "shuttle-space":
      return (
        "shuttle-space",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.shuttleSpace)
      ); // ?f=classic&s=solid
    case "skull":
      return (
        "skull",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.skull)
      ); // ?f=classic&s=solid
    case "skull-crossbones":
      return (
        "skull-crossbones",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.skullCrossbones)
      ); // ?f=classic&s=solid
    case "snowflake":
      return (
        "snowflake",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.snowflake)
      ); // ?f=classic&s=solid
    case "spider":
      return (
        "spider",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.spider)
      ); // ?f=classic&s=solid
    case "star":
      return (
        "star",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.star)
      ); // ?f=classic&s=solid
    case "store":
      return (
        "store",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.store)
      ); // ?f=classic&s=solid
    case "sun":
      return (
        "sun",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.sun)
      ); // ?f=classic&s=solid
    case "tag":
      return (
        "tag",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.tag)
      ); // ?f=classic&s=solid
    case "tent":
      return (
        "tent",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.tent)
      ); // ?f=classic&s=solid
    case "tents":
      return (
        "tents",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.tents)
      ); // ?f=classic&s=solid
    case "tooth":
      return (
        "tooth",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.tooth)
      ); // ?f=classic&s=solid
    case "tree":
      return (
        "tree",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.tree)
      ); // ?f=classic&s=solid
    case "trophy":
      return (
        "trophy",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.trophy)
      ); // ?f=classic&s=solid
    case "user-shield":
      return (
        "user-shield",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.userShield)
      ); // ?f=classic&s=solid
    case "wand-magic-sparkles":
      return (
        "wand-magic-sparkles",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.wandMagicSparkles)
      ); // ?f=classic&s=solid
    case "wand-sparkles":
      return (
        "wand-sparkles",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.wandSparkles)
      ); // ?f=classic&s=solid
    case "yin-yang":
      return (
        "yin-yang",
        CustomFaIcon(
            noPadding: true,
            size: size,
            color: color,
            icon: FontAwesomeIcons.yinYang)
      ); // ?f=classic&s=solid

    default:
      return (
        "missing",
        CustomFaIcon(
          noPadding: true,
          color: color,
          size: size,
          icon: FontAwesomeIcons.a,
        )
      );
  }
}
