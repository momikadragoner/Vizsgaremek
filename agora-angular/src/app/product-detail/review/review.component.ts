import { Component, Input, OnChanges, OnInit, Output, SimpleChanges } from '@angular/core';
import { faArrowUp, faArrowDown, faStar } from '@fortawesome/free-solid-svg-icons';
import { EventEmitter } from '@angular/core';
import { animate, style, transition, trigger } from '@angular/animations';
import { ThrowStmt } from '@angular/compiler';
import { Product, ratingToArray } from '../../services/product.service'
import { Review, ReviewService, ReviewVote } from 'src/app/services/review.service';

@Component({
  selector: 'app-review',
  templateUrl: './review.component.html',
  styleUrls: ['./review.component.scss'],
  animations: [
    trigger('addUpvote', [
      transition(':increment', [
        style({ transform: 'translateY(-1rem)', backgroundColor: 'transparent' }),
        animate('0.4s',
          style({ transform: 'translateY(0rem)', backgroundColor: '#859C62' }))
      ])
    ]),
    trigger('addDownvote', [
      transition(':decrement', [
        style({ transform: 'translateY(1rem)', backgroundColor: 'transparent' }),
        animate('0.4s',
          style({ transform: 'translateY(0rem)', backgroundColor: '#C26969' }))
      ])
    ])
  ]
})
export class ReviewComponent implements OnChanges {

  faArrowUp = faArrowUp;
  faArrowDown = faArrowDown;
  faStar = faStar;

  @Input() productId: number = 0;
  @Input() review: Review = new Review();
  @Output() reviewChange = new EventEmitter<Review>();
  vote: ReviewVote = new ReviewVote();
  baseVotes:number = 0;
  extraVotes:number = 0;

  constructor(
    private reviewService: ReviewService
  ) {

  }

  ngOnInit(): void {
  }

  ngOnChanges(changes: SimpleChanges) {
    this.baseVotes = this.review.points;
    this.vote.productId = this.productId;
    this.vote.reviewId = this.review.reviewId;
    this.vote.userId = this.reviewService.currentUser.userId;
  }

  upvote() {
    if (this.vote.vote == "up") {
      this.vote.vote = undefined;
      this.extraVotes = 0;
      this.deleteVote();
    }
    else{
      this.vote.vote = "up"
      this.extraVotes = 1;
      this.sendVote();
    }
    this.review.points = this.baseVotes + this.extraVotes;
  }

  downvote() {
    if (this.vote.vote == "down") {
      this.vote.vote = undefined;
      this.extraVotes = 0;
      this.deleteVote();
    }
    else{
      this.vote.vote = "down";
      this.extraVotes = -1;
      this.sendVote();
    }
    this.review.points = this.baseVotes + this.extraVotes;
  }

  sendVote() {
    this.reviewService.postReviewVote(this.vote).subscribe();
  }
  deleteVote() {
    this.reviewService.deleteReview(this.review.reviewId).subscribe();
  }

  ratingToArray = ratingToArray;

  addContent(value: any) {
    this.reviewChange.emit(value);
  }
}
