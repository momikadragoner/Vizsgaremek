using System;
using System.Collections.Generic;

#nullable disable

namespace agora_test_data_generator.Models
{
    public partial class ReviewVote
    {
        public int ReviewVoteId { get; set; }
        public int ProductId { get; set; }
        public int ReviewId { get; set; }
        public int MemberId { get; set; }
        public string Vote { get; set; }
        public DateTime? VotedAt { get; set; }

        public virtual Member Member { get; set; }
        public virtual Product Product { get; set; }
        public virtual Review Review { get; set; }
    }
}
