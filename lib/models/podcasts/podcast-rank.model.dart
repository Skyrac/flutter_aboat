enum Rank { NewComer, Receiver, Hodler }

extension RankId on Rank {
  int get id {
    switch (this) {
      case Rank.NewComer:
        return 0;
      case Rank.Receiver:
        return 1;
      case Rank.Hodler:
        return 2;
    }
  }
}

Rank? PodcastRankfromNumber(int? id) {
  if (id == null) {
    return null;
  }
  switch (id) {
    case 0:
      return Rank.NewComer;
    case 1:
      return Rank.Receiver;
    case 2:
      return Rank.Hodler;
  }
  return null;
}

String? PodcastRankNamefromRank(Rank? rank) {
  if (rank == null) {
    return null;
  }
  switch (rank) {
    case Rank.NewComer:
      return "Newcomer";
    case Rank.Receiver:
      return "Receiver";
    case Rank.Hodler:
      return "Hodler";
  }
}

String? PodcastMultiplerfromRank(Rank? rank) {
  if (rank == null) {
    return null;
  }
  switch (rank) {
    case Rank.NewComer:
      return "x1.5";
    case Rank.Receiver:
      return "x1.25";
    case Rank.Hodler:
      return "x1.1";
  }
}
