enum PodcastRank { NewComer, Receiver, Hodler }

extension RankId on PodcastRank {
  int get id {
    switch (this) {
      case PodcastRank.NewComer:
        return 0;
      case PodcastRank.Receiver:
        return 1;
      case PodcastRank.Hodler:
        return 2;
    }
  }
}

PodcastRank? PodcastRankfromNumber(int? id) {
  if (id == null) {
    return null;
  }
  switch (id) {
    case 0:
      return PodcastRank.NewComer;
    case 1:
      return PodcastRank.Receiver;
    case 2:
      return PodcastRank.Hodler;
  }
  return null;
}

String? PodcastRankNamefromRank(PodcastRank? rank) {
  if (rank == null) {
    return null;
  }
  switch (rank) {
    case PodcastRank.NewComer:
      return "Newcomer";
    case PodcastRank.Receiver:
      return "Receiver";
    case PodcastRank.Hodler:
      return "Hodler";
  }
}

String? PodcastMultiplerfromRank(PodcastRank? rank) {
  if (rank == null) {
    return null;
  }
  switch (rank) {
    case PodcastRank.NewComer:
      return "x1.5";
    case PodcastRank.Receiver:
      return "x1.25";
    case PodcastRank.Hodler:
      return "x1.1";
  }
}
