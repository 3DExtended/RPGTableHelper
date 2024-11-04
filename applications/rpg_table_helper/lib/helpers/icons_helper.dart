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
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.anchor)
      ); // ?f=classic&s=solid
    case "biohazard":
      return (
        "biohazard",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.biohazard)
      ); // ?f=classic&s=solid
    case "bolt":
      return (
        "bolt",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.bolt)
      ); // ?f=classic&s=solid
    case "bolt-lightning":
      return (
        "bolt-lightning",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.boltLightning)
      ); // ?f=classic&s=solid
    case "bomb":
      return (
        "bomb",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.bomb)
      ); // ?f=classic&s=solid
    case "bone":
      return (
        "bone",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.bone)
      ); // ?f=classic&s=solid
    case "book":
      return (
        "book",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.book)
      ); // ?f=classic&s=solid
    case "book-open":
      return (
        "book-open",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.bookOpen)
      ); // ?f=classic&s=solid
    case "broom":
      return (
        "broom",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.broom)
      ); // ?f=classic&s=solid
    case "burst":
      return (
        "burst",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.burst)
      ); // ?f=classic&s=solid
    case "campground":
      return (
        "campground",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.campground)
      ); // ?f=classic&s=solid
    case "carrot":
      return (
        "carrot",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.carrot)
      ); // ?f=classic&s=solid
    case "cat":
      return (
        "cat",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.cat)
      ); // ?f=classic&s=solid
    case "chess-rook":
      return (
        "chess-rook",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.chessRook)
      ); // ?f=classic&s=solid
    case "chess-king":
      return (
        "chess-king",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.chessKing)
      ); // ?f=classic&s=solid
    case "chess-queen":
      return (
        "chess-queen",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.chessQueen)
      ); // ?f=classic&s=solid
    case "chess-knight":
      return (
        "chess-knight",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.chessKnight)
      ); // ?f=classic&s=solid
    case "circle-radiation":
      return (
        "circle-radiation",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.circleRadiation)
      ); // ?f=classic&s=solid
    case "clock":
      return (
        "clock",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.clock)
      ); // ?f=classic&s=solid
    case "cloud-bolt":
      return (
        "cloud-bolt",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.cloudBolt)
      ); // ?f=classic&s=solid
    case "cloud-moon":
      return (
        "cloud-moon",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.cloudMoon)
      ); // ?f=classic&s=solid
    case "cloud-showers-heavy":
      return (
        "cloud-showers-heavy",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.cloudShowersHeavy)
      ); // ?f=classic&s=solid
    case "cloud-sun":
      return (
        "cloud-sun",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.cloudSun)
      ); // ?f=classic&s=solid
    case "clover":
      return (
        "clover",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.clover)
      ); // ?f=classic&s=solid
    case "comment":
      return (
        "comment",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.comment)
      ); // ?f=classic&s=solid
    case "comments":
      return (
        "comments",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.comments)
      ); // ?f=classic&s=solid
    case "compass":
      return (
        "compass",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.compass)
      ); // ?f=classic&s=solid
    case "compass-drafting":
      return (
        "compass-drafting",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.compassDrafting)
      ); // ?f=classic&s=solid
    case "cow":
      return (
        "cow",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.cow)
      ); // ?f=classic&s=solid
    case "cross":
      return (
        "cross",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.cross)
      ); // ?f=classic&s=solid
    case "crosshairs":
      return (
        "crosshairs",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.crosshairs)
      ); // ?f=classic&s=solid
    case "crow":
      return (
        "crow",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.crow)
      ); // ?f=classic&s=solid
    case "crown":
      return (
        "crown",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.crown)
      ); // ?f=classic&s=solid
    case "dice":
      return (
        "dice",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.dice)
      ); // ?f=classic&s=solid
    case "dice-d20":
      return (
        "dice-d20",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.diceD20)
      ); // ?f=classic&s=solid
    case "dice-six":
      return (
        "dice-six",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.diceSix)
      ); // ?f=classic&s=solid
    case "dog":
      return (
        "dog",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.dog)
      ); // ?f=classic&s=solid
    case "dove":
      return (
        "dove",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.dove)
      ); // ?f=classic&s=solid
    case "dragon":
      return (
        "dragon",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.dragon)
      ); // ?f=classic&s=solid
    case "droplet":
      return (
        "droplet",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.droplet)
      ); // ?f=classic&s=solid
    case "drumstick-bite":
      return (
        "drumstick-bite",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.drumstickBite)
      ); // ?f=classic&s=solid
    case "dungeon":
      return (
        "dungeon",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.dungeon)
      ); // ?f=classic&s=solid
    case "earth-europe":
      return (
        "earth-europe",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.earthEurope)
      ); // ?f=classic&s=solid
    case "egg":
      return (
        "egg",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.egg)
      ); // ?f=classic&s=solid
    case "envelope":
      return (
        "envelope",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.envelope)
      ); // ?f=classic&s=solid
    case "explosion":
      return (
        "explosion",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.explosion)
      ); // ?f=classic&s=solid
    case "eye":
      return (
        "eye",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.eye)
      ); // ?f=classic&s=solid
    case "feather":
      return (
        "feather",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.feather)
      ); // ?f=classic&s=solid
    case "feather-pointed":
      return (
        "feather-pointed",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.featherPointed)
      ); // ?f=classic&s=solid
    case "file":
      return (
        "file",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.file)
      ); // ?f=classic&s=solid
    case "fingerprint":
      return (
        "fingerprint",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.fingerprint)
      ); // ?f=classic&s=solid
    case "fire":
      return (
        "fire",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.fire)
      ); // ?f=classic&s=solid
    case "fire-flame-curved":
      return (
        "fire-flame-curved",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.fireFlameCurved)
      ); // ?f=classic&s=solid
    case "fish-fins":
      return (
        "fish-fins",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.fishFins)
      ); // ?f=classic&s=solid
    case "flag":
      return (
        "flag",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.flag)
      ); // ?f=classic&s=solid
    case "flask":
      return (
        "flask",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.flask)
      ); // ?f=classic&s=solid
    case "frog":
      return (
        "frog",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.frog)
      ); // ?f=classic&s=solid
    case "gavel":
      return (
        "gavel",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.gavel)
      ); // ?f=classic&s=solid
    case "gear":
      return (
        "gear",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.gear)
      ); // ?f=classic&s=solid
    case "gears":
      return (
        "gears",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.gears)
      ); // ?f=classic&s=solid
    case "gem":
      return (
        "gem",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.gem)
      ); // ?f=classic&s=solid
    case "ghost":
      return (
        "ghost",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.ghost)
      ); // ?f=classic&s=solid
    case "gift":
      return (
        "gift",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.gift)
      ); // ?f=classic&s=solid
    case "glasses":
      return (
        "glasses",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.glasses)
      ); // ?f=classic&s=solid
    case "gun":
      return (
        "gun",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.gun)
      ); // ?f=classic&s=solid
    case "hammer":
      return (
        "hammer",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.hammer)
      ); // ?f=classic&s=solid
    case "hand-holding-heart":
      return (
        "hand-holding-heart",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.handHoldingHeart)
      ); // ?f=classic&s=solid
    case "hand-holding-medical":
      return (
        "hand-holding-medical",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.handHoldingMedical)
      ); // ?f=classic&s=solid
    case "hat-cowboy":
      return (
        "hat-cowboy",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.hatCowboy)
      ); // ?f=classic&s=solid
    case "hat-wizard":
      return (
        "hat-wizard",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.hatWizard)
      ); // ?f=classic&s=solid
    case "heart":
      return (
        "heart",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.heart)
      ); // ?f=classic&s=solid
    case "heart-circle-bolt":
      return (
        "heart-circle-bolt",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.heartCircleBolt)
      ); // ?f=classic&s=solid
    case "helicopter":
      return (
        "helicopter",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.helicopter)
      ); // ?f=classic&s=solid
    case "hippo":
      return (
        "hippo",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.hippo)
      ); // ?f=classic&s=solid
    case "horse":
      return (
        "horse",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.horse)
      ); // ?f=classic&s=solid
    case "hourglass":
      return (
        "hourglass",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.hourglass)
      ); // ?f=classic&s=solid
    case "hourglass-half":
      return (
        "hourglass-half",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.hourglassHalf)
      ); // ?f=classic&s=solid
    case "house-chimney":
      return (
        "house-chimney",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.houseChimney)
      ); // ?f=classic&s=solid
    case "house":
      return (
        "house",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.house)
      ); // ?f=classic&s=solid
    case "ice-cream":
      return (
        "ice-cream",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.iceCream)
      ); // ?f=classic&s=solid
    case "igloo":
      return (
        "igloo",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.igloo)
      ); // ?f=classic&s=solid
    case "industry":
      return (
        "industry",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.industry)
      ); // ?f=classic&s=solid
    case "infinity":
      return (
        "infinity",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.infinity)
      ); // ?f=classic&s=solid
    case "jet-fighter":
      return (
        "jet-fighter",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.jetFighter)
      ); // ?f=classic&s=solid
    case "jet-fighter-up":
      return (
        "jet-fighter-up",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.jetFighterUp)
      ); // ?f=classic&s=solid
    case "key":
      return (
        "key",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.key)
      ); // ?f=classic&s=solid
    case "kiwi-bird":
      return (
        "kiwi-bird",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.kiwiBird)
      ); // ?f=classic&s=solid
    case "landmark":
      return (
        "landmark",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.landmark)
      ); // ?f=classic&s=solid
    case "leaf":
      return (
        "leaf",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.leaf)
      ); // ?f=classic&s=solid
    case "lemon":
      return (
        "lemon",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.lemon)
      ); // ?f=classic&s=solid
    case "lightbulb":
      return (
        "lightbulb",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.lightbulb)
      ); // ?f=classic&s=solid
    case "link":
      return (
        "link",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.link)
      ); // ?f=classic&s=solid
    case "link-slash":
      return (
        "link-slash",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.linkSlash)
      ); // ?f=classic&s=solid
    case "list":
      return (
        "list",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.list)
      ); // ?f=classic&s=solid
    case "list-check":
      return (
        "list-check",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.listCheck)
      ); // ?f=classic&s=solid
    case "location-arrow":
      return (
        "location-arrow",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.locationArrow)
      ); // ?f=classic&s=solid
    case "location-crosshairs":
      return (
        "location-crosshairs",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.locationCrosshairs)
      ); // ?f=classic&s=solid
    case "location-dot":
      return (
        "location-dot",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.locationDot)
      ); // ?f=classic&s=solid
    case "lock":
      return (
        "lock",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.lock)
      ); // ?f=classic&s=solid
    case "lock-open":
      return (
        "lock-open",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.lockOpen)
      ); // ?f=classic&s=solid
    case "magnifying-glass":
      return (
        "magnifying-glass",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.magnifyingGlass)
      ); // ?f=classic&s=solid
    case "map":
      return (
        "map",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.map)
      ); // ?f=classic&s=solid
    case "map-location-dot":
      return (
        "map-location-dot",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.mapLocationDot)
      ); // ?f=classic&s=solid
    case "martini-glass":
      return (
        "martini-glass",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.martiniGlass)
      ); // ?f=classic&s=solid
    case "medal":
      return (
        "medal",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.medal)
      ); // ?f=classic&s=solid
    case "meteor":
      return (
        "meteor",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.meteor)
      ); // ?f=classic&s=solid
    case "microchip":
      return (
        "microchip",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.microchip)
      ); // ?f=classic&s=solid
    case "microphone":
      return (
        "microphone",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.microphone)
      ); // ?f=classic&s=solid
    case "microphone-slash":
      return (
        "microphone-slash",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.microphoneSlash)
      ); // ?f=classic&s=solid
    case "moon":
      return (
        "moon",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.moon)
      ); // ?f=classic&s=solid
    case "mortar-pestle":
      return (
        "mortar-pestle",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.mortarPestle)
      ); // ?f=classic&s=solid
    case "mosque":
      return (
        "mosque",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.mosque)
      ); // ?f=classic&s=solid
    case "motorcycle":
      return (
        "motorcycle",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.motorcycle)
      ); // ?f=classic&s=solid
    case "mountain":
      return (
        "mountain",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.mountain)
      ); // ?f=classic&s=solid
    case "mountain-sun":
      return (
        "mountain-sun",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.mountainSun)
      ); // ?f=classic&s=solid
    case "music":
      return (
        "music",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.music)
      ); // ?f=classic&s=solid
    case "otter":
      return (
        "otter",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.otter)
      ); // ?f=classic&s=solid
    case "paintbrush":
      return (
        "paintbrush",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.paintbrush)
      ); // ?f=classic&s=solid
    case "palette":
      return (
        "palette",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.palette)
      ); // ?f=classic&s=solid
    case "paw":
      return (
        "paw",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.paw)
      ); // ?f=classic&s=solid
    case "pen-nib":
      return (
        "pen-nib",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.penNib)
      ); // ?f=classic&s=solid
    case "people-group":
      return (
        "people-group",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.peopleGroup)
      ); // ?f=classic&s=solid
    case "pepper-hot":
      return (
        "pepper-hot",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.pepperHot)
      ); // ?f=classic&s=solid
    case "person-running":
      return (
        "person-running",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.personRunning)
      ); // ?f=classic&s=solid
    case "person-swimming":
      return (
        "person-swimming",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.personSwimming)
      ); // ?f=classic&s=solid
    case "piggy-bank":
      return (
        "piggy-bank",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.piggyBank)
      ); // ?f=classic&s=solid
    case "place-of-worship":
      return (
        "place-of-worship",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.placeOfWorship)
      ); // ?f=classic&s=solid
    case "plane":
      return (
        "plane",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.plane)
      ); // ?f=classic&s=solid
    case "puzzle-piece":
      return (
        "puzzle-piece",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.puzzlePiece)
      ); // ?f=classic&s=solid
    case "radiation":
      return (
        "radiation",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.radiation)
      ); // ?f=classic&s=solid
    case "receipt":
      return (
        "receipt",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.receipt)
      ); // ?f=classic&s=solid
    case "robot":
      return (
        "robot",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.robot)
      ); // ?f=classic&s=solid
    case "rocket":
      return (
        "rocket",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.rocket)
      ); // ?f=classic&s=solid
    case "sailboat":
      return (
        "sailboat",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.sailboat)
      ); // ?f=classic&s=solid
    case "scale-balanced":
      return (
        "scale-balanced",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.scaleBalanced)
      ); // ?f=classic&s=solid
    case "screwdriver-wrench":
      return (
        "screwdriver-wrench",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.screwdriverWrench)
      ); // ?f=classic&s=solid
    case "seedling":
      return (
        "seedling",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.seedling)
      ); // ?f=classic&s=solid
    case "shield":
      return (
        "shield",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.shield)
      ); // ?f=classic&s=solid
    case "shield-halved":
      return (
        "shield-halved",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.shieldHalved)
      ); // ?f=classic&s=solid
    case "shield-heart":
      return (
        "shield-heart",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.shieldHeart)
      ); // ?f=classic&s=solid
    case "shoe-prints":
      return (
        "shoe-prints",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.shoePrints)
      ); // ?f=classic&s=solid
    case "shop":
      return (
        "shop",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.shop)
      ); // ?f=classic&s=solid
    case "shrimp":
      return (
        "shrimp",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.shrimp)
      ); // ?f=classic&s=solid
    case "shuttle-space":
      return (
        "shuttle-space",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.shuttleSpace)
      ); // ?f=classic&s=solid
    case "skull":
      return (
        "skull",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.skull)
      ); // ?f=classic&s=solid
    case "skull-crossbones":
      return (
        "skull-crossbones",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.skullCrossbones)
      ); // ?f=classic&s=solid
    case "snowflake":
      return (
        "snowflake",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.snowflake)
      ); // ?f=classic&s=solid
    case "spider":
      return (
        "spider",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.spider)
      ); // ?f=classic&s=solid
    case "star":
      return (
        "star",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.star)
      ); // ?f=classic&s=solid
    case "store":
      return (
        "store",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.store)
      ); // ?f=classic&s=solid
    case "sun":
      return (
        "sun",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.sun)
      ); // ?f=classic&s=solid
    case "tag":
      return (
        "tag",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.tag)
      ); // ?f=classic&s=solid
    case "tent":
      return (
        "tent",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.tent)
      ); // ?f=classic&s=solid
    case "tents":
      return (
        "tents",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.tents)
      ); // ?f=classic&s=solid
    case "tooth":
      return (
        "tooth",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.tooth)
      ); // ?f=classic&s=solid
    case "tree":
      return (
        "tree",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.tree)
      ); // ?f=classic&s=solid
    case "trophy":
      return (
        "trophy",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.trophy)
      ); // ?f=classic&s=solid
    case "user-shield":
      return (
        "user-shield",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.userShield)
      ); // ?f=classic&s=solid
    case "wand-magic-sparkles":
      return (
        "wand-magic-sparkles",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.wandMagicSparkles)
      ); // ?f=classic&s=solid
    case "wand-sparkles":
      return (
        "wand-sparkles",
        CustomFaIcon(
            size: size, color: color, icon: FontAwesomeIcons.wandSparkles)
      ); // ?f=classic&s=solid
    case "yin-yang":
      return (
        "yin-yang",
        CustomFaIcon(size: size, color: color, icon: FontAwesomeIcons.yinYang)
      ); // ?f=classic&s=solid

    default:
      return (
        "missing",
        CustomFaIcon(
          color: color,
          size: size,
          icon: FontAwesomeIcons.a,
        )
      );
  }
}
