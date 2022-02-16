import { HttpClient, HttpErrorResponse, HttpHeaders } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { catchError, throwError } from "rxjs";
import { Auth } from "./auth";

@Injectable()
export class FollowService {

    constructor(private http: HttpClient) { }

    currentUser = Auth.currentUser;

    rootURL = '/api';

    postFollow( userId: number) {
        let follow = {
            "follower": this.currentUser.userId,
            "following": userId
        }
        return this.http.post<object>(this.rootURL + '/post-follow', follow)
            .pipe(
                catchError(error => this.handleError(error))
            );
    }

    // deleteFollow(followingId:number) {
    //     return this.http.delete(this.rootURL + '/delete-follow/')
    //         .pipe(
    //             catchError(this.handleError)
    //         );
    // }

    private handleError(error: HttpErrorResponse) {
        if (error.status === 0) {
            // A client-side or network error occurred. Handle it accordingly.
            console.error('An error occurred:', error.error);
        } else {
            // The backend returned an unsuccessful response code.
            // The response body may contain clues as to what went wrong.
            console.error(
                `Backend returned code ${error.status}, body was: `, error.error);
        }
        // Return an observable with a user-facing error message.
        return throwError(() =>
            'Something bad happened; please try again later.');
    }

}