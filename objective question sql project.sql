-- 1. To find out the duplicate or null values
select username, count(*) as number_of_users
from users 
group by username
having count(*)>1;

select * from users
where username is NULL;

-- to remove the null value
DELETE FROM users
WHERE username IS NULL;

-- 2.the distribution of user activity levels (e.g., number of posts, likes, comments) across the user base
SELECT u.id AS user_id, u.username,
       COUNT(DISTINCT p.id) AS num_posts,
       COUNT(DISTINCT l.photo_id) AS num_likes,
       COUNT(DISTINCT c.id) AS num_comments
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON u.id = l.user_id
LEFT JOIN comments c ON u.id = c.user_id
GROUP BY u.id, u.username;

-- 3. Calculate the average number of tags per post (photo_tags and photos tables).

with tag_count as (select count(pt.tag_id) as tags_count
from photos p 
inner join photo_tags pt on p.id = pt.photo_id
group by p.id)
select avg(tags_count) as avg_number_of_tags_per_post
from tag_count;

-- 4.Identify the top users with the highest engagement rates (likes, comments) on their posts and rank them.

SELECT u.username, 
       COUNT(l.user_id) + COUNT(c.id) AS total_engagement,
       COUNT(p.id) AS num_posts,
       round((COUNT(l.user_id) + COUNT(c.id)) / COUNT(p.id),2) AS engagement_rate
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON p.id = l.photo_id
LEFT JOIN comments c ON p.id = c.photo_id
GROUP BY u.id
ORDER BY engagement_rate DESC;

-- 5. users have the highest number of followers and followings
-- To find the highest number of followers:

SELECT followee_id AS user_id, COUNT(follower_id) AS num_followers
FROM follows
GROUP BY followee_id
ORDER BY num_followers DESC;

-- To find the highest number of followings:

SELECT follower_id AS user_id, COUNT(followee_id) AS num_followings
FROM follows
GROUP BY follower_id
ORDER BY num_followings DESC;

-- 6.the average engagement rate (likes, comments) per post for each user.

SELECT u.username, 
       (COUNT(l.user_id) + COUNT(c.id)) / COUNT(p.id) AS avg_engagement_rate
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
LEFT JOIN likes l ON p.id = l.photo_id
LEFT JOIN comments c ON p.id = c.photo_id
GROUP BY u.id;

-- 7. the list of users who have never liked any post (users and likes tables).

select u.username
from users u 
left join likes l on u.id = l.user_id
where l.user_id is null;

-- 8. correlations between user activity levels and specific content types (e.g., photos, videos, reels)? How can this information guide content creation and curation strategies


-- 10.the total number of likes, comments, and photo tags for each user.
  SELECT u.username, 
         COUNT(DISTINCT l.user_id) AS total_likes, 
         COUNT(DISTINCT c.id) AS total_comments, 
         COUNT(DISTINCT pt.tag_id) AS total_tags
  FROM users u
  LEFT JOIN photos p ON u.id = p.user_id
  LEFT JOIN likes l ON p.id = l.photo_id
  LEFT JOIN comments c ON p.id = c.photo_id
  LEFT JOIN photo_tags pt ON p.id = pt.photo_id
  GROUP BY u.id;

-- 11. Rank users based on their total engagement (likes, comments, shares) over a month.
WITH posts AS (
    SELECT u.username,
           u.id AS user_id,
           COUNT(DISTINCT l.user_id) AS total_likes, 
           COUNT(DISTINCT c.id) AS total_comments
    FROM users u
    LEFT JOIN likes l ON u.id = l.user_id
    LEFT JOIN comments c ON u.id = c.user_id
    GROUP BY u.username, u.id
)
SELECT p.username,
       SUM(p.total_likes + p.total_comments) AS total_engagement
FROM posts p
join users u  on p.user_id = u.id
WHERE u.created_at BETWEEN '2024-07-01' AND '2024-07-31'
GROUP BY p.username
ORDER BY total_engagement DESC;

use ig_clone
select * from photo_tags limit 10;