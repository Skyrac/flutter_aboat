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
