import { animate, style, transition, trigger } from '@angular/animations';
import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { FontAwesomeModule, FaIconLibrary } from '@fortawesome/angular-fontawesome'
import { faStar as farStar } from '@fortawesome/free-regular-svg-icons'
import { faStar as fasStar } from '@fortawesome/free-solid-svg-icons'
import { AuthService } from 'src/app/account-forms/services/auth.service';
import { Review, ReviewService } from 'src/app/services/review.service';

@Component({
  selector: 'review-form',
  templateUrl: './review-form.component.html',
  styleUrls: ['./review-form.component.scss'],
  animations: [
    trigger('visibilityChange', [
      transition(':leave', [
        style({ opacity: 1 }),
        animate('0.2s',
          style({ opacity: 0, height: 0 }))
      ]),
      transition(':enter', [
        style({ opacity: 0, height: 0 }),
        animate('0.2s',
          style({ opacity: 1 }))
      ])
    ])
  ]
})
export class ReviewFormComponent implements OnInit {

  farStar = farStar;
  fasStar = fasStar;

  @Output() modalState = new EventEmitter<boolean>();
  @Output() reviewSent = new EventEmitter<Review>();
  @Input() productId: number = 0;

  rating: number = -1;
  currentUser = this.authService.getUserDetails()[0];

  constructor(
    library: FaIconLibrary,
    private fb: FormBuilder,
    private reviewService: ReviewService,
    private authService: AuthService
  ) {
    library.addIcons(fasStar, farStar);
  }

  reviewForm = this.fb.group({
    title: ['', [Validators.required, Validators.maxLength(30)]],
    review: ['', Validators.required]
  });

  solidStars(i: number) {
    this.rating = i;
  }

  back($event: any) {
    $event.preventDefault();
    this.modalState.emit(false);
  }

  onSubmit() {
    let form = this.reviewForm.value;
    let newReview: Review = new Review()
    newReview.content = form.review;
    newReview.title = form.title;
    newReview.rating = (this.rating + 1);
    newReview.userId = this.currentUser.member_id;
    newReview.productId = this.productId;
    newReview.userFirstName = this.currentUser.first_name;
    newReview.userLastName = this.currentUser.last_name;
    newReview.points = 0;
    this.reviewService.postReview(newReview)
      .subscribe({
        next: data => {
          this.modalState.emit(false);
          this.reviewSent.emit(newReview);
        }
      });
  }

  ngOnInit(): void {
  }

}
